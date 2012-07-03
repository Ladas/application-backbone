module ViewMixins
  def Link
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
      if settings['url']
        url += settings['url']
      else
        if settings['symlink_outer_controller']
          url += "/" + settings['symlink_outer_controller']
        end
        if settings['symlink_outer_id']
          url += "/" + settings['symlink_outer_id']
        end
        if settings['symlink_controller']
          url += "/" + settings['symlink_controller']
        end
        if settings['symlink_id']
          url += "/" + settings['symlink_id']
        end
        if settings['symlink_action']
          url += "/" + settings['symlink_action']
        end
        if settings['symlink_params']
          url += settings['params']
        end
      end
      url
    end

  end
end