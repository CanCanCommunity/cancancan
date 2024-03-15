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

<div class="sponsors">
  <a href="https://www.pennylane.com/" target="_blank">
    <img src="/pennylane.svg" alt="Pennylane"/>
  </a>
  <a href="https://www.honeybadger.io/" target="_blank">
    <img src="/honeybadger.svg" alt="Honeybadger"/>
  </a>
  <a href="https://jobs.goboony.com/o/full-stack-ruby-on-rails-engineer" target="_blank">
    <img src="/goboony.png" alt="Goboony"/>
  </a>
  <a href="https://www.renuo.ch" target="_blank">
    <img src="/renuo.png" alt="Renuo AG"/>
  </a>
</div>

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


<style scoped>
.sponsors {
  display: flex;
  justify-content: space-around;
  align-items: center;
  flex-wrap: wrap;
  margin: 2em 0;
  gap: 10px;
}

img {
  height: 100px;
  width: 200px;
  padding: 20px;
  background: white;
  border-radius: 10px;
  object-fit: contain;
  display: block;
  margin: auto;
}
</style>
