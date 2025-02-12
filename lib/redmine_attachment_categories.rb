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
  def self.setup
    #------------------------------------------------------------------------------------- #
    # patch redmine core plugin
    #------------------------------------------------------------------------------------- #
    Redmine::Acts::Attachable::InstanceMethods.send(:include, RedmineAttachmentCategories::Patches::ActsAsAttachablePatch)

    #------------------------------------------------------------------------------------- #
    # patch helpers and controllers 
    #------------------------------------------------------------------------------------- #
    ApplicationHelper.send(:include, RedmineAttachmentCategories::Patches::ApplicationHelperPatch)
    Attachment.send(:include, RedmineAttachmentCategories::Patches::AttachmentPatch)
    AttachmentsController.send(:include, RedmineAttachmentCategories::Patches::AttachmentsControllerPatch)
    AttachmentsHelper.send(:include, RedmineAttachmentCategories::Patches::AttachmentsHelperPatch)
    AutoCompletesController.send(:include, RedmineAttachmentCategories::Patches::AutoCompletesControllerPatch)
  end
end
