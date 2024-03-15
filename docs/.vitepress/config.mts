import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "CanCanCan",
  description: "The authorization Gem for Ruby on Rails.",
  head: [
    ['link', { rel: "apple-touch-icon", sizes: "180x180", href: "/apple-touch-icon.png" }],
    ['link', { rel: "icon", type: "image/png", sizes: "32x32", href: "/favicon-32x32.png" }],
    ['link', { rel: "icon", type: "image/png", sizes: "16x16", href: "/favicon-16x16.png" }],
    ['link', { rel: "mask-icon", href: "./safari-pinned-tab.svg", color: "#3c3ebf" }],
    ['link', { rel: "manifest", href: "/manifest.json" }],

    ['link', { rel: "icon", href: "/favicon.ico", type: "image/x-icon" }],
    ['link', { rel: "shortcut icon", href: "/favicon.ico", type: "image/x-icon" }],
  ],
  sitemap: {
    hostname: 'https://cancancan.com'
  },
  cleanUrls: true,
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Docs', link: '/README' },
    ],
    externalLinkIcon: true,

    lastUpdated: {
      formatOptions: {
        dateStyle: 'medium',
      }
    },
    editLink: {
      pattern: 'https://github.com/CanCanCommunity/cancancan/edit/main/docs/:path'
    },
    search: {
      provider: 'local'
    },

    logo: '/cancancan.png',

    sidebar: [
      {
        text: 'Summary',
        items: [
          { text: 'Introduction', link: '/introduction' },
          { text: 'Installation', link: '/installation' },
          { text: 'Define and check abilities', link: '/define_check_abilities' },
          { text: 'Controller helpers', link: '/controller_helpers' },
          { text: 'Fetching records', link: '/fetching_records' },
          { text: 'Cannot', link: '/cannot' },
          { text: 'Hash of conditions', link: '/hash_of_conditions' },
          { text: 'Combine Abilities', link: '/combine_abilities' },
          { text: 'Check abilities - avoid mistakes', link: '/check_abilities_mistakes' },
          { text: 'Handling CanCan::AccessDenied', link: '/handling_access_denied' },
          { text: 'Customize controller helpers', link: '/changing_defaults' },
          { text: 'Accessing request data', link: '/accessing_request_data' },
          { text: 'SQL strategies', link: '/sql_strategies' },
          { text: 'Accessible attributes', link: '/accessible_attributes' },
          { text: 'Testing', link: '/testing' },
          { text: 'Internationalization', link: '/internationalization' }
        ]
      },
      {
        text: 'Further topics',
        items: [
          { text: 'Migrating', link: '/migrating' },
          { text: 'Debugging Abilities', link: '/debugging' },
          { text: 'Split your ability file', link: '/split_ability' },
          { text: 'Define Abilities - best practices', link: '/define_abilities_best_practices' },
          { text: 'Abilities in database', link: '/abilities_in_database' },
          { text: 'Role-based Authorization', link: '/role_based_authorization' },
          { text: 'Model Adapter', link: '/model_adapter' },
          { text: 'Rules compression', link: '/rules_compression' },
          { text: 'Inherited Resources', link: '/inherited_resources' },
          { text: 'Devise', link: '/devise' },
          { text: 'FriendlyId', link: '/friendly_id' }
        ]
      }
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/CanCanCommunity/cancancan' }
    ]
  }
})
