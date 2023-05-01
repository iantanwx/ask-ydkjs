module ApplicationHelper
  def og_and_twitter_meta_tags
    tags = []

    # Replace these with your own data
    tags << tag.meta(property: 'og:title', content: 'AskYDKJS')
    tags << tag.meta(property: 'og:type', content: 'website')
    tags << tag.meta(property: 'og:image', content: image_url('ydkjs.jpeg'))
    tags << tag.meta(property: 'og:url', content: request.original_url)
    tags << tag.meta(property: 'og:description', content: 'Chat with the You Don\'t Know JS series of books.')

    tags << tag.meta(name: 'twitter:card', content: 'summary_large_image')
    tags << tag.meta(name: 'twitter:title', content: 'AskYDKJS')
    tags << tag.meta(name: 'twitter:site', content: '@iantanwx')
    tags << tag.meta(name: 'twitter:description', content: 'Chat with the You Don\'t Know JS series of books.')
    tags << tag.meta(name: 'twitter:image', content: image_url('ydkjs.jpeg'))

    safe_join(tags)
  end
end
