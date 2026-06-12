# Jekyll plugin:
# 1. Prepend image_cdn (without /img/ prefix) to local image URLs when configured
# 2. Wrap <img> tags in <picture> with WebP source for modern browsers

Jekyll::Hooks.register :site, :post_read do |site|
  $image_cdn = site.config['image_cdn'] || ''
end

def cdn_url(local_src)
  # local_src: "/img/path/to/image.jpg" or "/img/path/to/image.png"
  if $image_cdn != ''
    # Strip /img/ prefix for CDN: /img/foo.jpg -> http://cdn/foo.jpg
    $image_cdn + local_src.sub(/^\/img/, '')
  else
    local_src
  end
end

def process_images(html)
  html.gsub(/<img[^>]*src="(\/[^"]*\.(jpg|jpeg|png))"[^>]*>/) do |match|
    img_tag = match
    src = $1
    ext = $2
    webp_local = src.sub(/\.(jpg|jpeg|png)$/i, '.webp')

    cdn_src = cdn_url(src)
    cdn_webp = cdn_url(webp_local)

    # Replace src in img tag with CDN URL
    new_img = img_tag.sub('src="' + src + '"', 'src="' + cdn_src + '"')

    # Check if webp file exists locally
    webp_path = File.join(Dir.pwd, webp_local.sub(/^\//, ''))
    if File.exist?(webp_path)
      %(<picture><source srcset="#{cdn_webp}" type="image/webp">#{new_img}</picture>)
    elsif $image_cdn != ''
      # CDN mode but no local webp: just update src
      new_img
    else
      img_tag
    end
  end
end

Jekyll::Hooks.register :posts, :post_render do |post|
  post.output = process_images(post.output)
end

Jekyll::Hooks.register :pages, :post_render do |page|
  next unless page.output
  page.output = process_images(page.output)
end
