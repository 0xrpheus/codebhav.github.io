---
layout: page
title: writings
permalink: /writings/
custom_js:
    - search
---

<div class="search-container">
  <input type="text" id="search-input" class="search-input" placeholder="Search posts...">
  <div id="search-results" class="search-results"></div>
</div>

<ul class="post-list">
  {% for post in site.posts %}
  <li class="post-item">
    <h2>
      <a class="post-link" href="{{ post.url | relative_url }}">{{ post.title }}</a>
    </h2>
    <p class="post-meta">
      <time>{{ post.date | date: "%B %d, %Y" }}</time>
      {% if post.tags %}
      <span class="post-tags">
        {% for tag in post.tags %}
        <a href="{{ '/writings/tags/' | append: tag | relative_url }}" class="tag">{{ tag }}</a>
        {% endfor %}
      </span>
      {% endif %}
    </p>
    <p class="post-excerpt">{{ post.excerpt }}</p>
  </li>
  {% endfor %}
</ul>
