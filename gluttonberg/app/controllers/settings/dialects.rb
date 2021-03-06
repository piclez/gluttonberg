module Gluttonberg
  module Settings
    class Dialects < Gluttonberg::Application
      include AdminController

      before :find_dialect, :only => [:delete, :edit, :delete, :update, :destroy]

      def index
        @dialects = Dialect.all
        display @dialects
      end

      def new
        only_provides :html
        @dialect = Dialect.new
        render
      end

      def edit
        render
      end

      def delete
        display_delete_confirmation(
          :title      => "Delete “#{@dialect.name}” dialect?",
          :action     => slice_url(:gluttonberg, :dialect, @dialect),
          :return_url => slice_url(:gluttonberg, :dialects)
        )
      end

      def create
        @dialect = Dialect.new(params["gluttonberg::dialect"])
        if @dialect.save
          redirect slice_url(:gluttonberg, :dialects)
        else
          render :new
        end
      end

      def update
        if @dialect.update_attributes(params["gluttonberg::dialect"]) || !@dialect.dirty?
          redirect slice_url(:gluttonberg, :dialects)
        else
          render :edit
        end
      end

      def destroy
        if @dialect.destroy
          redirect slice_url(:gluttonberg, :dialects)
        else
          raise BadRequest
        end
      end

      private

      def find_dialect
        @dialect = Dialect.get(params[:id])
        raise NotFound unless @dialect
      end

    end
  end
end