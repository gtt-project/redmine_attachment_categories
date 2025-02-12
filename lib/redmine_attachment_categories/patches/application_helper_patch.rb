# encoding: utf-8
#
# Redmine plugin for having a category tag on attachments
#
# Copyright © 2018 Stephan Wenzel <stephan.wenzel@drwpatent.de>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

module RedmineAttachmentCategories
  module Patches 
    module ApplicationHelperPatch
    
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          
          if Rails::VERSION::MAJOR >= 5
          
            alias_method :thumbnail_tag_without_attachment_category, :thumbnail_tag
            alias_method :thumbnail_tag, :thumbnail_tag_with_attachment_category
            
            alias_method :link_to_attachment_without_attachment_category, :link_to_attachment
            alias_method :link_to_attachment, :link_to_attachment_with_attachment_category

            alias_method :format_object_without_attachment_category, :format_object
            alias_method :format_object, :format_object_with_attachment_category
          else
            alias_method_chain :thumbnail_tag, :attachment_category
            alias_method_chain :link_to_attachment, :attachment_category
            alias_method_chain :format_object, :attachment_category
          end
          
          # ------------------------------------------------------------------------------#
          # creates an attachment_category_tag
          # ------------------------------------------------------------------------------#
          def attachment_category_tag(attachment_category, tag, html_options={})
            if attachment_category.present?
              _css_color = contrast_css_color( attachment_category.html_color )
              _tag = content_tag tag, 
                                 h(attachment_category.name),
                                 {:class => "attachment_category " + Setting['plugin_redmine_attachment_categories']['attachment_category_style'].presence || "attachment_category_default",
                                  :style => "background:#{attachment_category.html_color};color:#{_css_color};"
                                 }.merge(html_options)
            else
              _tag = content_tag tag, 
                                 "&nbsp;".html_safe,
                                 {:class => "attachment_category "
                                 }.merge(html_options)
            end 
            _tag.html_safe
          end #def
          
          # ------------------------------------------------------------------------------#
          # calculates black or white font-color for a given background color
          # ------------------------------------------------------------------------------#
          def contrast_css_color( _html_color )
            begin
              _rgb = _html_color.downcase.scan(/[0-9a-f]{2}/).map(&:hex)
              (0.213 * _rgb[0] + 0.715 * _rgb[1] + 0.072 * _rgb[2])/255 > 0.5 ? "black" : "white"
            rescue
              "black"
            end
          end #def
          
        end #base
        
      end #self
      
      module InstanceMethods
      
          # ------------------------------------------------------------------------------#
          # Generates a link to an attachment.
          # Options:
          # * :text - Link text (default to attachment filename)
          # * :download - Force download (default: false)
          # ------------------------------------------------------------------------------#
          def link_to_attachment_with_attachment_category(attachment, options={})
            text = options.delete(:text) || attachment.filename
            if Redmine::VERSION::MAJOR >= 4
              if options.delete(:download)
                route_method = :download_named_attachment_url
                options[:filename] = attachment.filename
              else
                route_method = :attachment_url
                # make sure we don't have an extraneous :filename in the options
                options.delete(:filename)
              end
              html_options = options.slice!(:only_path, :filename)
              options[:only_path] = true unless options.key?(:only_path)
              url = send(route_method, attachment, options)
            else
              route_method = options.delete(:download) ? :download_named_attachment_url : :named_attachment_url
              html_options = options.slice!(:only_path)
              options[:only_path] = true unless options.key?(:only_path)
              url = send(route_method, attachment, attachment.filename, options)
            end
            link_to(text, url, html_options) + (route_method == :download_named_attachment_url ? "" : attachment_category_tag(attachment.attachment_category,:span))
          end

          def format_object_with_attachment_category(object, html=true, &block)
            if block_given?
              object = yield object
            end
            case object.class.name
            when 'Attachment'
              if Redmine::VERSION.to_s >= '4.2'
                if html
                  content_tag(
                    :span,
                    link_to_attachment_without_attachment_category(object) +
                    link_to_attachment_without_attachment_category(
                      object,
                      :class => ['icon-only', 'icon-download'],
                      :title => l(:button_download),
                      :download => true
                    )
                  )
                else
                  object.filename
                end
              else
                html ? link_to_attachment_without_attachment_category(object) : object.filename
              end
            else
              format_object_without_attachment_category(object, html, &block)
            end
          end

          # ------------------------------------------------------------------------------#
          # creates a thumbnail tag, which honors
          # the attachment_category
          # ------------------------------------------------------------------------------#
          def thumbnail_tag_with_attachment_category(attachment, options={})
            thumbnail_tag_without_attachment_category(attachment) + ( options.key?(:no_attribute_tag) ? "" : "<br />".html_safe + attachment_category_tag(attachment.attachment_category, :span) )
          end
          
       end #module
      
       module ClassMethods
       
       end #module
      
    end #module
  end #module
end #module
