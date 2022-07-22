# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'
class GithubInfoController < ApplicationController
  before_action :github_data, only: [:show]
  def index; end

  def show
    @github_login = @query_result['data']['user']['login']
    @github_name = @query_result['data']['user']['name']
    @github_repos = @query_result['data']['user']['repositories']['nodes']
  end

  private

  def github_data
    @query_result = CLIENT.query(GITHUB_QUERY, variables: { username: params[:gh_login] }).to_h
    redirect_to root_path, notice: @query_result['errors'][0]['message'] if @query_result.key?('errors')
  end

  HTTP = GraphQL::Client::HTTP.new('https://api.github.com/graphql') do
    def headers(_context)
      {
        'Authorization' => "Bearer #{GithubGraphqlApi::Application.credentials.github_access_token}"
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
