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
#
# 1.0.3
#        runing on redmine 3.4.x
#
# 2.0.0 
#        runing on redmine 4.x
# 3.0.0
#        runing on redmine 5.x

Redmine::Plugin.register :redmine_attachment_categories do
  name 'Attachment Categories'
  author 'Stephan Wenzel'
  description 'This is a plugin for Redmine for having a category tag on attachments'
  version '3.0.0'
  url 'https://github.com/HugoHasenbein/redmine_attachment_categories'
  author_url 'https://github.com/HugoHasenbein/redmine_attachment_categories'
  
#-----------------------------------------------------------------------------------------
# Plugin setting
#-----------------------------------------------------------------------------------------
  settings :default => {'attachment_category_style'     => 'attachment_category_default',
                        'disable_auto_completes'        => false,
                        'disable_attachment_archive'    => false
                        },
           :partial => 'settings/redmine_attachment_categories/plugin_settings'
           
#-----------------------------------------------------------------------------------------
# Menus
#-----------------------------------------------------------------------------------------
  menu :admin_menu, 
       :attachment_categories, # name and id
       { controller: 'attachment_categories', action: 'index' },
       after:   :enumerations, 
       html:    { class: 'icon icon-attachment' },
       caption: :label_attachment_category_plural
       
end

#---------------------------------------------------------------------------------------
# Plugin Library
#---------------------------------------------------------------------------------------
if Rails.version > '6.0' && Rails.autoloaders.zeitwerk_enabled?
  Rails.application.config.after_initialize do
    RedmineAttachmentCategories.setup
  end
else
  require 'redmine_attachment_categories'
  Rails.configuration.to_prepare do
    RedmineAttachmentCategories.setup
  end
end

#---------------------------------------------------------------------------------------
# hooks 
#---------------------------------------------------------------------------------------
require File.expand_path('../lib/redmine_attachment_categories/hooks/layout_base_hook', __FILE__)

#---------------------------------------------------------------------------------------
# utilities 
#---------------------------------------------------------------------------------------
require File.expand_path('../lib/redmine_attachment_categories/lib/rac_file', __FILE__)
