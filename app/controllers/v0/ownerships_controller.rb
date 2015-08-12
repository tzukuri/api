class V0::OwnershipsController < ApplicationController
    def index
        current_user.current_ownerships
    end

    def create
    end

    def destroy
    end
end
