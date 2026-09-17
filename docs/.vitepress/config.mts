import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "GDUMU - Knowledge base",
  description: "Knowledge lekip GDC MU",
  themeConfig: {
    // Enable built-in search bar
    search: {
      provider: 'local'
    },

    // Navigation bar (top right)
    nav: [
      { text: 'Home', link: '/' },
      { text: 'AWS', link: '/aws/' },
      { text: 'Linux', link: '/linux/' },
      { text: 'Windows', link: '/windows/' },
      { text: 'TIL', link: '/til/' },
    ],

    // Left sidebar navigation
    sidebar: [
      {
        text: 'Examples',
        items: [
          { text: 'What is this?', link: 'what-is-this'}
        ]
      },
      {
        text: 'AWS Cloud',
        collapsed: false,
        items: [
          { text: 'EC2 Boot Recovery', link: '/aws/ec2-boot-recovery/ec2-boot-recovery' },
        ]
      },
      {
        text: 'Windows Administration',
        collapsed: false,
        items: [
          { text: 'Overview', link: '/windows/' },
        ]
      },
      {
        text: 'Linux',
        collapsed: false,
        items: [
          { text: 'Overview', link: '/linux/' },
        ]
      },
      {
        text: 'TIL',
        collapsed: false,
        items: [
          { text: 'Overview', link: '/til/' },
        ]
      },
    ],

    // Link to your actual private organization repository
    socialLinks: [
      { icon: 'github', link: 'https://github.com/raifcoonjah-tw/gdumu-knowledge-base-test' }
    ]
  }
})