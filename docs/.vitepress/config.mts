import { defineConfig } from 'vitepress'
import { generateSidebar } from 'vitepress-sidebar'

export default defineConfig({
  title: "GDUMU - Knowledge base",
  description: "Knowledge lekip GDC MU",
  themeConfig: {
    search: {
      provider: 'local'
    },
    nav: [
      { text: 'Home', link: '/' },
      { text: 'AWS', link: '/aws/' },
      { text: 'Linux', link: '/linux/' },
      { text: 'Windows', link: '/windows/' },
      { text: 'TIL 💡', link: '/til/' },
    ],
    sidebar: generateSidebar({
      documentRootPath: '/docs',
      useFolderTitleFromIndexFile: true,
      useFolderLinkFromIndexFile: true,
      useTitleFromFileHeading: true,
      useTitleFromFrontmatter: true,
      hyphenToSpace: true,
      capitalizeFirst: true,
      collapseDepth: 2,
      // Regex patterns to exclude public and .vitepress folders
      excludePattern: ['public', '\\.vitepress']
    }),
    socialLinks: [
      { icon: 'github', link: 'https://github.com/raifcoonjah-tw/gdumu-knowledge-base-test' }
    ]
  }
})