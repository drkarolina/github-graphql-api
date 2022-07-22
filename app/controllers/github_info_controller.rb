# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'
class GithubInfoController < ApplicationController
  before_action :get_github_data, only: [:show]
  def index; end

  def show
    @github_login = @query_result['data']['user']['login']
    @github_name = @query_result['data']['user']['name']
    @github_repos = @query_result['data']['user']['repositories']['nodes']
  end

  private

  def get_github_data
    @query_result = CLIENT.query(GITHUB_QUERY, variables: { username: params[:gh_login] }).to_h
    redirect_to root_path, notice: @query_result['errors'][0]['message'] if @query_result.key?('errors')
  end

  GITHUB_ACCESS_TOKEN = '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'
  HTTP = GraphQL::Client::HTTP.new('https://api.github.com/graphql') do
    def headers(_context)
      {
        'Authorization' => "Bearer #{GITHUB_ACCESS_TOKEN}"
      }
    end
  end

  CLIENT = GraphQL::Client.new(schema: GraphQL::Client.load_schema('db/schema.json'),
                               execute: HTTP)

  GITHUB_QUERY = CLIENT.parse <<-'GRAPHQL'
    query($username: String!) {
        user(login: $username) {
            login
            name
            repositories(first: 50) {
                nodes {
                    name
                    url
                }
            }
        }
    } 
  GRAPHQL
end
