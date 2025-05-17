---
layout: page
title: photos
permalink: /photos/
custom_js:
    - gallery
---

<div class="photo-grid">
  {% for photo in site.photos %}
  <div class="photo-item" data-full-img="{{ '/assets/images/photos/fullsize/' | append: photo.image | relative_url }}">
    <a href="#" class="photo-link">
      <img src="{{ '/assets/images/photos/thumbs/' | append: photo.image | relative_url }}" alt="{{ photo.title }}">
    </a>
  </div>
  {% endfor %}
</div>

<div id="photo-modal" class="photo-modal">
  <span class="close-button">&times;</span>
  <div class="modal-content">
    <img id="full-size-image" src="" alt="">
  </div>
</div>
