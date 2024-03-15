---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: CanCanCan
  text: Developer guide
  tagline: The authorization Gem for Ruby on Rails.
  image: 
    src: /cancancan.png
    style:
      # for dark mode
      backgroundColor: '#fff'
      borderRadius: '50%'
      padding: '20px'
  actions:
    - theme: brand
      text: Get Started
      link: /README
    - theme: alt
      text: Installation
      link: /installation
    - theme: alt
      text: GitHub
      link: https://github.com/CanCanCommunity/cancancan

features:
  - title: "🔐 Secure Your Rails: CanCanCan's Authorization Mastery"
    details: "Empowering developers to define and manage user permissions seamlessly."
  - title: "🚀 Simplify with CanCanCan: Streamlined Permissions for Ruby"
    details: "Dive into efficient, easy-to-manage access control for your Ruby applications."
  - title: "✨ Permission Perfection with CanCanCan"
    details: "Revolutionizing Ruby on Rails authorization with a unified, easy-to-use system."
---

## Our Sponsor

<VPSponsors :data="sponsors" />

<script setup>
import { VPSponsors } from 'vitepress/theme'

let sponsors = [
  {
    name: 'Pennylane',
    img: '/pennylane.svg',
    url: 'https://www.pennylane.com/'
  },
  {
    name: 'Honeybadger',
    img: '/honeybadger.svg',
    url: 'https://www.honeybadger.io/'
  },
  {
    name: 'Goboony',
    img: '/goboony.png',
    url: 'https://jobs.goboony.com'
  },
  {
    name: 'Renuo AG',
    img: '/renuo.png',
    url: 'https://www.renuo.ch'
  }
]
</script>

_Do you want to sponsor CanCanCan and show your logo here? Check our [Sponsors Page](https://github.com/sponsors/coorasse)._

## Questions?

If you have any question or doubt regarding CanCanCan which you cannot find the solution to in the
[documentation](./README.md), please
[open a question on Stackoverflow](http://stackoverflow.com/questions/ask?tags=cancancan) with tag
[cancancan](http://stackoverflow.com/questions/tagged/cancancan)

## Bugs?

If you find a bug please add an [issue on GitHub](https://github.com/CanCanCommunity/cancancan/issues) or fork the project and send a pull request.

## Special Thanks

Thanks to our Sponsors and to all the [CanCanCan contributors](https://github.com/CanCanCommunity/cancancan/contributors).
See the [CHANGELOG](https://github.com/CanCanCommunity/cancancan/blob/main/CHANGELOG.md) for the full list.
