# frozen_string_literal: true
#
# https://github.com/dawidd6/action-homebrew-bump-formula

require 'formula'

class Object
  def false?
    nil?
  end
end

class String
  def false?
    empty? || strip == 'false'
  end
end

module Homebrew
  module_function

  def print_command(*cmd)
    puts "[command]#{cmd.join(' ').gsub("\n", ' ')}"
  end

  def brew(*args)
    print_command 'brew', *args
    return if ENV['DEBUG']

    safe_system 'brew', *args
  end

  def git(*args)
    print_command 'git', *args
    return if ENV['DEBUG']

    safe_system 'git', *args
  end

  def read_brew(*args)
    print_command 'brew', *args
    return if ENV['DEBUG']

    Utils.safe_popen_read('brew', *args).chomp
  end

  def read_git(*args)
    print_command 'git', *args
    return if ENV['DEBUG']

    Utils.safe_popen_read('git', *args).chomp
  end

  # Get inputs
  token = ENV['TOKEN']
  tap = ENV['TAP']
  formula = ENV['FORMULA']

  # Set needed HOMEBREW environment variables
  ENV['HOMEBREW_GITHUB_API_TOKEN'] = token

  # Tap the tap if desired
  brew 'tap', tap unless tap.blank?

  # Support multiple formulae in input and change to full names if tap
  unless formula.blank?
    formula = formula.split(/[ ,\n]/).reject(&:blank?)
    formula = formula.map { |f| tap + '/' + f } unless tap.blank?
  end

  # Get livecheck info
  json = read_brew 'livecheck',
    '--quiet',
    '--newer-only',
    '--full-name',
    '--json',
    *("--tap=#{tap}" if !tap.blank? && formula.blank?),
    *(formula unless formula.blank?)
    json = JSON.parse json

    changed = 0

    # Loop over livecheck info
    json.each do |info|
      # Skip if there is no version field
      next unless info['version']
      changed += 1

      # Get info about formula
      formula = info['formula']
      version = info['version']['latest']
      old_version = info['version']['current']

      path = Formula[formula].path
      pairs = [[%Q(version "#{old_version}"), %Q(version "#{version}")]]
      Utils::Inreplace.inreplace_pairs(path, pairs)
    end

    # Die if error occured
    odie "No changes!" if changed < 1
end
