#!/usr/bin/env ruby

# Copyright 2019 Google
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'cocoapods'
require 'set'

# Enable ruby options after 'require' because cocoapods is noisy
$VERBOSE = true   # ruby -w
#$DEBUG = true    # ruby --debug

def usage()
  script = File.basename($0)
  STDERR.puts <<~EOF
  USAGE: #{script} podspec [options]

  podspec is the podspec to lint

  options can be any options for pod spec lint

  script options:
    --no-analyze: don't run Xcode analyze on this podspec
    --ignore-local-podspecs: list of podspecs that should not be added to
      "--include-podspecs" list. If not specified, then all podspec
      dependencies will be passed to "--include-podspecs".
      Example: --ignore-local-podspecs=GoogleDataTransport.podspec
  EOF
end

def main(args)
  if args.size < 1 then
    usage()
    exit(1)
  end

  STDOUT.sync = true

  podspec_file = args[0]
  ignore_local_podspecs = []

  puts find_local_deps(podspec_file, ignore_local_podspecs.to_set).join(',').prepend('{').concat('}')

  # command = %w(pod lib lint --skip-tests --allow-warnings --platforms=ios,macos)

  # # Split arguments that need to be processed by the script itself and passed
  # # to the pod command.
  # pod_args = []
  # ignore_local_podspecs = []
  # analyze = true

  # args.each do |arg|
  #   if arg =~ /--ignore-local-podspecs=(.*)/
  #     ignore_local_podspecs = $1.split(',')
  #   elsif arg =~ /--no-analyze/
  #     analyze = false
  #   else
  #     pod_args.push(arg)
  #   end
  # end

  # podspec_file = pod_args[0]
  # # Figure out which dependencies are local
  # deps = find_local_deps(podspec_file, ignore_local_podspecs.to_set)
  # arg = make_include_podspecs(deps)
  # command.push(arg) if arg
  # command.push('--analyze') if analyze

  # command.push(*pod_args)
  # puts command.join(' ')

  # # Run the lib lint command in a thread.
  # pod_lint_status = 1
  # t = Thread.new do
  #   with_removed_social_media_url(podspec_file) do
  #     system(*command)
  #     pod_lint_status = $?.exitstatus
  #   end
  # end

  # Print every minute since linting can run for >10m without output.
  # number_of_times_checked = 0
  # while t.alive? do
  #   sleep 1.0
  #   number_of_times_checked += 1
  #   if (number_of_times_checked % 60) == 0 then
  #     puts "Still working, running for #{number_of_times_checked / 60}min."
  #   end
  # end

  # exit(pod_lint_status)
end

# Loads all the specs (inclusing subspecs) from the given podspec file.
def load_specs(podspec_file)
  trace('loading', podspec_file)
  results = []

  spec = Pod::Spec.from_file(podspec_file)
  results.push(spec)

  results.push(*(spec.subspecs - spec.non_library_specs))
  return results
end

# Finds all dependencies of the given list of specs
def all_deps(specs)
  result = Set[]

  specs.each do |spec|
    spec.dependencies.each do |dep|
      name = dep.name.sub(/\/.*/, '')
      result.add(name)
    end
  end

  result = result.to_a
  trace('   deps', *result)
  return result
end

# Given a podspec file, finds all local dependencies that have a local podspec
# in the same directory. Modifies seen to include all seen podspecs, which
# guarantees that a given podspec will only be processed once.
def find_local_deps(podspec_file, seen = Set[])
  # Mark the current podspec seen to prevent a pod from depending upon itself
  # (as might happen if a subspec of the pod depends upon another subpsec of
  # the pod.
  seen.add(File.basename(podspec_file))

  results = []
  spec_dir = File.dirname(podspec_file)

  specs = load_specs(podspec_file)
  deps = all_deps(specs)

  deps.each do |dep_name|
    dep_file = File.join(spec_dir, "#{dep_name}.podspec")
    if File.exist?(dep_file) then
      dep_podspec = File.basename(dep_file)
      if seen.add?(dep_podspec)
        # Depend on the podspec we found and any podspecs it depends upon.
        results.push(dep_podspec)
        results.push(*find_local_deps(dep_file, seen))
      end
    end
  end

  return results
end

# Returns an --include-podspecs argument that indicates the given deps are
# locally available. Returns nil if deps is empty.
def make_include_podspecs(deps)
  return nil if deps.empty?

  if deps.size == 1 then
    deps_joined = deps[0]
  else
    deps_joined  = "{" + deps.join(',') + "}"
  end
  return "--include-podspecs=#{deps_joined}"
end

def trace(*args)
  return if not $DEBUG

  STDERR.puts(args.join(' '))
end

# Edits the given podspec file to remove the social_media_url, yields, then
# restores the file to its original condition.  Validating of the social URL
# can be very flaky (see #3416). Remove it from spec to let the actual tests
# pass.
def with_removed_social_media_url(spec)
  podspec_content = File.read(spec)
  updated_podspec_content =
      podspec_content.gsub("s.social_media_url = ", "# s.social_media_url = ")
  write_file(spec, updated_podspec_content)
  yield

ensure
  write_file(spec, podspec_content)
end

# Writes the text in +contents+ to the file named by +filename+.
def write_file(filename, contents)
  File.open(filename, "w") do |file|
    file.write(contents)
  end
end

main(ARGV)
