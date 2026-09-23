import { createRequire } from 'module'
const require = createRequire(import.meta.url)

export default {
  async load() {
    const feeds = {
      aws: 'https://aws.amazon.com/about-aws/whats-new/recent/feed/',
      azure: 'https://azure.microsoft.com/en-us/blog/feed/'
    }

    const fetchFeed = async (url) => {
      try {
        const res = await fetch(url, {
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'application/rss+xml, application/xml, text/xml, */*'
          }
        })

        if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`)

        const xmlText = await res.text()
        const items = []

        // 1. Check for standard RSS <item> tags
        if (xmlText.includes('<item>')) {
          const itemRegex = /<item>([\s\S]*?)<\/item>/g
          let match

          while ((match = itemRegex.exec(xmlText)) !== null && items.length < 5) {
            const content = match[1]
            let title = content.match(/<title>([\s\S]*?)<\/title>/)?.[1] || 'No title'
            title = title.replace(/<!\[CDATA\[(.*?)\]\]>/g, '$1').replace(/<[^>]+>/g, '').trim()

            let link = content.match(/<link>([\s\S]*?)<\/link>/)?.[1] || '#'
            link = link.replace(/<!\[CDATA\[(.*?)\]\]>/g, '$1').trim()

            const pubDate = content.match(/<pubDate>([\s\S]*?)<\/pubDate>/)?.[1]?.trim() || ''

            items.push({ title, link, pubDate })
          }
        } 
        // 2. Fallback for Atom <entry> tags
        else if (xmlText.includes('<entry>')) {
          const entryRegex = /<entry>([\s\S]*?)<\/entry>/g
          let match

          while ((match = entryRegex.exec(xmlText)) !== null && items.length < 5) {
            const content = match[1]
            let title = content.match(/<title[\s\S]*?>([\s\S]*?)<\/title>/)?.[1] || 'No title'
            title = title.replace(/<!\[CDATA\[(.*?)\]\]>/g, '$1').replace(/<[^>]+>/g, '').trim()

            const linkMatch = content.match(/<link[\s\S]*?href=["']([^"']+)["']/) || content.match(/<link>([\s\S]*?)<\/link>/)
            const link = linkMatch ? linkMatch[1].replace(/<!\[CDATA\[(.*?)\]\]>/g, '$1').trim() : '#'

            const pubDate = content.match(/<updated>([\s\S]*?)<\/updated>/)?.[1]?.trim() || 
                            content.match(/<published>([\s\S]*?)<\/published>/)?.[1]?.trim() || ''

            items.push({ title, link, pubDate })
          }
        }

        return items
      } catch (err) {
        console.error(`Failed to load feed from ${url}:`, err.message)
        return []
      }
    }

    return {
      aws: await fetchFeed(feeds.aws),
      azure: await fetchFeed(feeds.azure)
    }
  }
}