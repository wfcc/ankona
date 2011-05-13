class NonauthorizedController < ApplicationController
  check_authorization
  load_and_authorize_resource
end
