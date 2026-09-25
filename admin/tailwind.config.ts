import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        cream: "#F7F6F2",
        charcoal: "#101010",
        flame: {
          DEFAULT: "#FF5C5C",
          hover: "#E84A4A",
          muted: "rgba(255, 92, 92, 0.12)",
        },
        surface: {
          light: "#FFFFFF",
          subtle: "#F0EFEA",
          dark: "#181818",
          darkSubtle: "#222222",
        },
      },
      fontFamily: {
        sans: ["var(--font-readex-pro)", "system-ui", "sans-serif"],
      },
    },
  },
  plugins: [],
};

export default config;
