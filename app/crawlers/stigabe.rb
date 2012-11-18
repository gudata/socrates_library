class Stigabe
  delegate :logger, :to => :main_app

  attr_reader :main_app

  def initialize main_app
    @main_app = main_app
  end

  def download_articles
    ((0 || Article.last.legacy_id)..117426).each do |legacy_id|
      article_url = "http://www.stigabe.com/index.php?tmp=2384867&t=#{legacy_id}"
      logger.debug article_url
      doc = Nokogiri::HTML(open(article_url))
      extract_data_from_article doc, legacy_id
    end
  end

  def run
    download_articles
  end

  private

  def get_id_and_parent legacy_category_id
    return [nil, nil] unless legacy_category_id

    category_ids = legacy_category_id.split(',')
    if category_ids.size == 2
      parent_id = category_ids.first
      category_id = category_ids.last
    else
      parent_id = nil
      category_id = category_ids.first
    end
    [parent_id, category_id]
  end

  # Take the category id from the menu/also the title
  def find_or_create_category doc
    active_category_element = doc.css('.art-vmenu li.active a').first
    return nil unless active_category_element

    legacy_category_id = extract_id_from_legacy_category_href(active_category_element.attributes['href'].value)

    category = Category.find_by_legacy_id(legacy_category_id)

    unless category
      #      (parent_id, category_id) = get_id_and_parent(legacy_category_id)
      title = doc.css('.art-vmenu li.active a').first.content.strip
      puts title
      category = Category.create({
          #          id: category_id,
          title: title,
          legacy_id: legacy_category_id,
          #          parent_id: parent_id,
        }
      )
    end

    category
  end

  def extract_data_from_article doc, legacy_article_id
    category = find_or_create_category doc

    title = doc.css('.art-post-inner.art-article h2').first.content rescue ''
    content = doc.css('.art-post-inner.art-article .topiccontentblock').first.content rescue ''
    date = doc.css('.topicstatscontainer span.topicstatsblockmain').first.content rescue ''
    if date
      date = Date.strptime date, '%d.%m.%Y' rescue 1.year.ago
    end

    article = Article.create({
        title: title,
        content:  content,
        date: date,
        legacy_id: legacy_article_id,
        category_id: category ? category.id : nil
      })

    extract_images doc, article
    extract_comments doc, article
    download_images article
    article
  end

  def download_images article
    article.images.each do |image|
      open("http://www.stigabe.com/#{image.original_url}") {|f|
        file_name = File.basename image.original_url
        file_dir = Pathname.new(image.original_url).dirname

        target_dir = File.join(@main_app.root, 'storage', file_dir)

        unless Dir.exists?(target_dir)
          puts "creating #{target_dir} from #{file_dir}"
          FileUtils.mkdir_p target_dir
        end

        file_path = File.join(target_dir, file_name)
        puts "storing #{file_path}"
        File.open(file_path, "wb") do |file|
          file.puts f.read
        end
      }
    end
  end

  def extract_images doc, article
    src = doc.css('#img-top-postcontent .topiciconframe img').first.attributes['src'].value rescue ''
    Image.create({
        original_url: src,
        article_image_flag: true,
        article_id: article.id,
      }) unless src.blank?

    doc.css('.art-post-inner.art-article .topiccontentblock img').each do |image_tag|
      src = image_tag.attributes['src'].value rescue ''
      Image.create({
          original_url: src,
          article_image_flag: false,
          article_id: article.id,
        }) unless src.blank?
    end
  end

  def extract_comments doc, article

    doc.search('#commentscontainer > div').each do |comment_block|
      next if comment_block.search('.commentposter .guestname').blank?
      author = comment_block.search('.commentposter .guestname').first.content rescue ''
      content = comment_block.search('.commentinner').first.content rescue ''
      title = comment_block.search('.commentheaderlink').first.content rescue ''
      Comment.create({
          author: author,
          content: content,
          title: title,
          article_id: article.id
        }
      )
    end

  end

  def to_params href
    uri = URI.parse(href)
    CGI.parse(uri.query)
  end

  # "index.php?tmp=907501073&c=5,4" => 5,4
  def extract_id_from_legacy_category_href href
    to_params(href)['c'].first
  end


end
#article_url = "http://www.stigabe.com/index.php?tmp=2384867&t=25"
#doc = Nokogiri::HTML(open(article_url))