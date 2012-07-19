module ViewMixins
  module Link
    def ajax_link_to(*args, &block)
      if block_given?
        options = args.first || {}
        html_options = args.second
        ######### additional logic by ladas ##############
        html_options ||= {}
        html_options['onclick'] = "parse_link_and_load_page($(this)); return false;"
        #########################################
        link_to(capture(&block), options, html_options)
      else
        name = args[0]
        options = args[1] || {}
        html_options = args[2]
        ######### additional logic by ladas ##############
        html_options ||= {}
        html_options['onclick'] = "parse_link_and_load_page($(this)); return false;"
        #########################################
        html_options = convert_options_to_data_attributes(options, html_options)
        url = url_for(options)

        href = html_options['href']
        tag_options = tag_options(html_options)

        href_attr = "href=\"#{ERB::Util.html_escape(url)}\"" unless href
        "<a #{href_attr}#{tag_options}>#{ERB::Util.html_escape(name || url)}</a>".html_safe
      end
    end

    def ajax_post_link_to(*args, &block)
      if block_given?
        options = args.first || {}
        html_options = args.second
        ######### additional logic by ladas ##############
        html_options ||= {}
        html_options['onclick'] = "parse_link_and_post($(this)); return false;"
        #########################################
        link_to(capture(&block), options, html_options)
      else
        name = args[0]
        options = args[1] || {}
        html_options = args[2]
        ######### additional logic by ladas ##############
        html_options ||= {}
        html_options['onclick'] = "parse_link_and_post($(this)); return false;"
        #########################################
        html_options = convert_options_to_data_attributes(options, html_options)
        url = url_for(options)

        href = html_options['href']
        tag_options = tag_options(html_options)

        href_attr = "href=\"#{ERB::Util.html_escape(url)}\"" unless href
        "<a #{href_attr}#{tag_options}>#{ERB::Util.html_escape(name || url)}</a>".html_safe
      end
    end

    # used only in jstree
    def link_tree(*args, &block)
      if block_given?
        options = args.first || {}
        html_options = args.second
        ######### additional logic by ladas ##############
        html_options ||= {}
        html_options['onclick'] = "parse_link_and_load_page($(this)); return false;"
        #########################################
        link_to(capture(&block), options, html_options)
      else
        name = args[0]
        options = args[1] || {}
        html_options = args[2]
        ######### additional logic by ladas ##############
        html_options ||= {}
        html_options['onclick'] = "parse_link_and_load_page($(this)); return false;"
        #########################################
        html_options = convert_options_to_data_attributes(options, html_options)
        url = url_for(options)

        href = html_options['href']
        tag_options = tag_options(html_options)

        href_attr = "href=\"#{ERB::Util.html_escape(url)}\"" unless href
        "<a #{href_attr}#{tag_options}>#{ERB::Util.html_escape(name || url)}</a>".html_safe
      end
    end

    def convert_settings_to_url settings_json
      # make sure its the same as build_url in ladas_loading.js

      settings = JSON.parse(settings_json)
      url = ""
      unless settings['url'].to_s.blank?
        url += settings['url'].to_s
      else
        unless settings['symlink_outer_controller'].to_s.blank?
          url += "/" + settings['symlink_outer_controller'].to_s
        end
        unless settings['symlink_outer_id'].to_s.blank?
          url += "/" + settings['symlink_outer_id'].to_s
        end
        unless settings['symlink_controller'].to_s.blank?
          url += "/" + settings['symlink_controller'].to_s
        end
        unless settings['symlink_id'].to_s.blank?
          url += "/" + settings['symlink_id'].to_s
        end
        unless settings['symlink_action'].to_s.blank?
          url += "/" + settings['symlink_action'].to_s
        end
        unless settings['symlink_params'].to_s.blank?
          url += settings['params'].to_s
        end
      end
      url
    end

  end
end