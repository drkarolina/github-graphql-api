require "graphql/client"
require "graphql/client/http"
class GithubInfoController < ApplicationController
    def index
    end

    def show
        @query_result = Client.query(IndexQuery, variables: {username: params[:gh_login]}).to_h
        if @query_result["data"]["user"]
            @github_login = @query_result["data"]["user"]["login"]
            @github_name = @query_result["data"]["user"]["name"]
            @github_repos = @query_result["data"]["user"]["repositories"]["nodes"]
        else
            redirect_to root_path, notice: "Oops! Something went wrong!"
        end
    end

    private
    GITHUB_ACCESS_TOKEN = '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'
    HTTP = GraphQL::Client::HTTP.new('https://api.github.com/graphql') do
        def headers(context)
          { 
            "Authorization" => "Bearer #{GITHUB_ACCESS_TOKEN}",
          }
        end
    end 
    
    Client = GraphQL::Client.new(schema: GraphQL::Client.load_schema("db/schema.json"), 
                                 execute: HTTP)
    
    IndexQuery = Client.parse <<-'GRAPHQL'
    query($username: String!) {
        user(login: $username) {
            login
            name
            repositories(first: 50, isFork: false) {
                nodes {
                    name
                    url
                }
            }
        }
    } 
    GRAPHQL
end
