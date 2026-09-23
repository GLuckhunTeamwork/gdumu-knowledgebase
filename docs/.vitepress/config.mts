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
      { text: 'Feeds 📡', link: '/cloud-feeds' }
    ],

    // Left sidebar navigation
    sidebar: [
      {
        text: 'Getting started',
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
          {
            text: 'Overview',
            link: '/windows/'
          },
          { text: 'DNS Server Configuration', link: '/windows/changing-dns/windows-dns-change' },
          {
            text: 'Patching',
            collapsed: false,
            items: [
              {
                text: 'Overview',
                link: '/windows/patching/'
              },
            ]
          },
        ]
      },
      {
        text: 'Linux',
        collapsed: false,
        items: [
          {
            text: 'Overview',
            link: '/linux/'
          },
          {
            text: 'Patching',
            collapsed: false,
            items: [
              {
                text: 'Overview',
                link: '/linux/patching/'
              },
            ]
          }
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