# frozen_string_literal: true

require_relative 'lib/number_flow/version'

Gem::Specification.new do |spec|
  spec.name = 'number_flow'
  spec.version = NumberFlow::VERSION
  spec.authors = ['dpaluy']
  spec.email = ['dpaluy@users.noreply.github.com']

  spec.summary = 'Rails helper + Stimulus digit flow transitions for integers.'
  spec.description = 'NumberFlow provides a Rails helper and Stimulus controller for smooth integer digit ' \
                     'transitions using gem-shipped CSS and JavaScript assets.'
  spec.homepage = 'https://github.com/dpaluy/number_flow#readme'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.4.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['documentation_uri'] = 'https://rubydoc.info/gems/number_flow'
  spec.metadata['source_code_uri'] = 'https://github.com/dpaluy/number_flow'
  spec.metadata['changelog_uri'] = 'https://github.com/dpaluy/number_flow/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/dpaluy/number_flow/issues'

  gemspec = File.basename(__FILE__)
  raw_files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true)
  end
  if raw_files.empty?
    raw_files = Dir.glob('**/*', File::FNM_DOTMATCH)
                   .reject { |file| File.directory?(file) || %w[. ..].include?(file) }
  end

  spec.files = raw_files.reject do |file|
    (file == gemspec) ||
      file.start_with?(*%w[
                         test/
                         spec/
                         Gemfile
                         Gemfile.lock
                         Rakefile
                         .gitignore
                         .github/
                         .rubocop.yml
                         docs/
                         .agents/
                         AGENTS.md
                         CLAUDE.md
                         .yardopts
                         pkg/
                       ]) ||
      file.end_with?('.gem')
  end
  spec.require_paths = ['lib']
  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']

  spec.add_dependency 'actionview', '>= 8.1.0'
  spec.add_dependency 'railties', '>= 8.1.0'
end
