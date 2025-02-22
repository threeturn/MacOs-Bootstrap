#
# Cookbook:: macbook_config
#
# Copyright:: Copyright 2025, Andrea C. Granata
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class Chef
  class Provider
    class Package
      class Homebrew < Chef::Provider::Package
        def brew_cmd_output(*command, **options)
          homebrew_uid = find_homebrew_uid(new_resource.respond_to?(:homebrew_user) && new_resource.homebrew_user)
          homebrew_user = Etc.getpwuid(homebrew_uid)
          homebrew_group = homebrew_user.gid

          logger.trace "Executing '#{homebrew_bin_path} #{command.join(" ")}' as user '#{homebrew_user.name}'"

          # allow the calling method to decide if the cmd should raise or not
          # brew_info uses this when querying out available package info since a bad
          # package name will raise and we want to surface a nil available package so that
          # the package provider can magically handle that
          shell_out_cmd = options[:allow_failure] ? :shell_out : :shell_out!

          output = send(shell_out_cmd, homebrew_bin_path, *command, user: homebrew_uid, group: homebrew_group, login: true, environment: { "HOME" => homebrew_user.dir, "RUBYOPT" => nil, "TMPDIR" => nil })
          output.stdout.chomp
        end
       end
    end
  end
end




