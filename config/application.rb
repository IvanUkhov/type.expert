require 'haml'
require 'uglifier'
require 'sprockets'

require File.expand_path('../../app/helpers/application_helper', __FILE__)

Sprockets.register_engine('.haml', Tilt::HamlTemplate)

class Application
  def call(env)
    case env['PATH_INFO']
    when /^.+(png|svg)$/
      browser.call(env)
    when /^.+(js|css)$/
      pipeline = build_pipeline(env)
      pipeline.call(env)
    else
      pipeline = build_pipeline(env)
      [ 200, {}, [ pipeline['application.html'].to_s ] ]
    end
  end

  private

  def browser
    @browser ||= Rack::Directory.new('public')
  end

  def build_pipeline(env)
    pipeline = Sprockets::Environment.new

    pipeline.append_path('app/assets/javascripts')
    pipeline.append_path('app/assets/stylesheets')
    pipeline.append_path('app/views/layouts')

    pipeline.context_class.class_eval do
      include ApplicationHelper

      define_method(:server_address) do
        env['HTTP_HOST']
      end
    end

    pipeline
  end
end