require 'nokogiri'
require 'net/http'
require 'uri'

class SemExtractor
  class Zemanta < SemExtractor
    
    def terms
      begin
        @categories = Nokogiri::XML(remote_xml).css('category').map { |h|  {"score" => h.css('confidence').first.content, "name" => h.css('name').first.content} }
        Nokogiri::XML(remote_xml).css('keyword').map { |h|  {"score" => h.css('confidence').first.content, "name" => h.css('name').first.content} }
      rescue
        []
      end
    end
    
    def categories
      terms if @categories == nil
      return @categories
    end

    def uri
      URI.parse(gateway)
    end

    def post_params
      {
        'method'        =>'zemanta.suggest',
        'api_key'       => @api_key,
        'return_images' => 0,
        'text'          => @context,
        'format'        => 'xml',
        'articles_limit' => 1,
        'return_categories' => 'dmoz'
      }
    end

  private
      def gateway
        'http://api.zemanta.com/services/rest/0.0/'
      end

      def remote_xml
        begin
          Net::HTTP.post_form(uri, post_params).body
        rescue => e
          $stderr.puts "Couldn't fetch from API: #{e.message}" if $VERBOSE
          nil
        end
      end
  end
end
