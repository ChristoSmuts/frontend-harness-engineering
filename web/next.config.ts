import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  outputFileTracingIncludes: {
    "/api/generate": ["./lib/emit/assets/**/*"],
  },
};

export default nextConfig;
