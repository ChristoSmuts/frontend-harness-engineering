import { HarnessFile } from "./claude";

export interface SkillSearchResult {
  id: string;
  name: string;
  description: string;
  installs: number;
  isDuplicate: boolean;
  slug: string;
}

export interface SkillDetail extends SkillSearchResult {
  files: Array<{
    name: string;
    content: string;
  }>;
}

export async function searchSkills(query: string): Promise<SkillSearchResult[]> {
  try {
    const response = await fetch(`https://skills.sh/api/v1/skills/search?q=${encodeURIComponent(query)}&limit=5`);
    if (!response.ok) return [];
    const data = await response.json();
    return (data as SkillSearchResult[]).filter(skill => !skill.isDuplicate);
  } catch (error) {
    console.error("Error searching skills:", error);
    return [];
  }
}

export async function getSkill(id: string): Promise<SkillDetail | null> {
  try {
    const response = await fetch(`https://skills.sh/api/v1/skills/${id}`);
    if (!response.ok) return null;
    return await response.json() as SkillDetail;
  } catch (error) {
    console.error("Error fetching skill detail:", error);
    return null;
  }
}

export async function getSkillsForDependencies(dependencies: string[]): Promise<HarnessFile[]> {
  const harnessFiles: HarnessFile[] = [];

  // Also include default skills
  const queries = [...new Set([...dependencies, "ui ux design", "frontend design"])];

  const searchPromises = queries.map(q => searchSkills(q));
  const searchResults = await Promise.all(searchPromises);

  const uniqueSkillIds = new Set<string>();
  const topSkills: SkillSearchResult[] = [];

  searchResults.flat().forEach(skill => {
    if (!uniqueSkillIds.has(skill.id)) {
      uniqueSkillIds.add(skill.id);
      topSkills.push(skill);
    }
  });

  // Limit concurrent fetches
  const detailPromises = topSkills.slice(0, 10).map(skill => getSkill(skill.id));
  const details = await Promise.all(detailPromises);

  details.forEach((detail, index) => {
    if (detail && detail.files) {
      const skillMeta = topSkills[index];
      detail.files.forEach(file => {
        harnessFiles.push({
          name: `agent-skills/${skillMeta.slug}/${file.name}`,
          content: file.content,
          description: detail.description,
          type: "From skills.sh",
          supportBadges: ["Universal"],
          installs: detail.installs,
          url: `https://skills.sh/skills/${detail.slug}`
        });
      });
    }
  });

  return harnessFiles;
}
