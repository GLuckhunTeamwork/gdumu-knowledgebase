---
title: Live Cloud RSS Feeds
---

<script setup>
import { data } from './feeds.data.js'

function formatDate(dateStr) {
  if (!dateStr) return ''
  try {
    return new Date(dateStr).toLocaleDateString(undefined, {
      month: 'short',
      day: 'numeric',
      year: 'numeric'
    })
  } catch {
    return dateStr
  }
}
</script>

# Live Cloud RSS Feeds

Stay updated with official architecture updates, service announcements, and release notes.

---

## ☁️ AWS Updates

<div class="rss-container">
  <h3>AWS What's New</h3>
  <ul v-if="data.aws && data.aws.length" class="feed-list">
    <li v-for="(item, index) in data.aws" :key="index" class="feed-item">
      <a :href="item.link" target="_blank" rel="noopener">{{ item.title }}</a>
      <span class="feed-date" v-if="item.pubDate"> — {{ formatDate(item.pubDate) }}</span>
    </li>
  </ul>
  <p v-else class="error">Unable to fetch AWS updates.</p>
</div>

---

## 🔷 Azure Updates

<div class="rss-container">
  <h3>Azure Service Updates</h3>
  <ul v-if="data.azure && data.azure.length" class="feed-list">
    <li v-for="(item, index) in data.azure" :key="index" class="feed-item">
      <a :href="item.link" target="_blank" rel="noopener">{{ item.title }}</a>
      <span class="feed-date" v-if="item.pubDate"> — {{ formatDate(item.pubDate) }}</span>
    </li>
  </ul>
  <p v-else class="error">Unable to fetch Azure updates.</p>
</div>

<style scoped>
.rss-container {
  margin: 1.5rem 0;
  padding: 1rem 1.25rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background-color: var(--vp-c-bg-soft);
}
.rss-container h3 {
  margin-top: 0;
  margin-bottom: 0.75rem;
}
.feed-list {
  padding-left: 1.2rem;
  margin: 0;
}
.feed-item {
  margin: 0.5rem 0;
  line-height: 1.4;
}
.feed-item a {
  color: var(--vp-c-brand-1);
  text-decoration: none;
}
.feed-item a:hover {
  text-decoration: underline;
}
.feed-date {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
}
.error {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
}
</style>