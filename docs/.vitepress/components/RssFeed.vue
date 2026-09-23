<template>
  <div class="rss-container">
    <h3>{{ title }}</h3>
    <div v-if="loading" class="loading">Fetching latest updates...</div>
    <div v-else-if="error" class="error">{{ error }}</div>
    <ul v-else class="feed-list">
      <li v-for="(item, index) in items" :key="index" class="feed-item">
        <a :href="item.link" target="_blank" rel="noopener">{{ item.title }}</a>
        <span class="feed-date" v-if="item.pubDate"> — {{ formatDate(item.pubDate) }}</span>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({
  url: String,
  title: String
})

const items = ref([])
const loading = ref(true)
const error = ref(null)

onMounted(async () => {
  try {
    // Use api.allorigins.win to bypass CORS restrictions safely in the browser
    const response = await fetch(`https://api.allorigins.win/get?url=${encodeURIComponent(props.url)}`)
    
    if (!response.ok) throw new Error('Network response failed')
    
    const data = await response.json()
    const parser = new DOMParser()
    const xmlDoc = parser.parseFromString(data.contents, 'text/xml')
    
    // Parse RSS <item> tags
    const xmlItems = Array.from(xmlDoc.querySelectorAll('item')).slice(0, 5)
    
    items.value = xmlItems.map(item => ({
      title: item.querySelector('title')?.textContent || 'No title',
      link: item.querySelector('link')?.textContent || '#',
      pubDate: item.querySelector('pubDate')?.textContent || ''
    }))
  } catch (err) {
    console.error('Failed to load RSS feed:', err)
    error.value = 'Unable to load feed content right now.'
  } finally {
    loading.value = false
  }
})

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
.loading, .error {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
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
</style>