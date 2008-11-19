module Gluttonberg
  module Library
    class Assets < Gluttonberg::Application
      include Gluttonberg::AdminController
      
      before :find_asset, :exclude => [:index, :category, :new, :create, :browser]

      def index
        @assets = Asset.all
        display @assets
      end
      
      def browser
        @assets = []
        @collections = AssetCollection.all(:order => [:name.desc])
        if params["no_frame"]
          partial(:browser_root)
        else
          render :layout => false
        end
      end
      
      def category
        provides :json
        @assets = Asset.all(:category => params[:category], :order => [:name.desc])
        if content_type == :json
          JSON.pretty_generate({
            :name     => params[:category].pluralize.capitalize,
            :backURL  => slice_url(:asset_browser, :no_frame => false),
            :markup   => partial("library/shared/asset_panels", :format => :html, :editing => false)
          })
        else
          render
        end
      end
      
      def show
        render
      end
      
      def new
        @asset = Asset.new
        prepare_to_edit
        render
      end
      
      def edit
        prepare_to_edit
        render
      end
      
      def delete
        display_delete_confirmation(
          :title      => "Delete “#{@asset.name}”?",
          :action     => slice_url(:asset, @asset),
          :return_url => slice_url(:asset, @asset)
        )
      end
      
      def create
        @asset = Asset.new(params["gluttonberg::asset"])
        if @asset.save
          redirect(slice_url(:asset, @asset))
        else
          prepare_to_edit
          render :new
        end
      end
      
      def update
        unless params["gluttonberg::asset"].has_key?('collection_ids') 
          # no collection ids were supplied so need to delete all collection associations
          @asset.clear_all_collections
        end

        # Create new AssetCollection if requested by the user
        if params["new_collection"]
          if params["new_collection"].has_key?('do_new_collection')
            if params["new_collection"].has_key?('new_collection_name')
              unless params["new_collection"]['new_collection_name'].blank?
                # Retireve the existing AssetCollection if it matches or create a new one
                the_collection = Gluttonberg::AssetCollection.first(:name => params["new_collection"]['new_collection_name'])
                unless the_collection
                  the_collection = Gluttonberg::AssetCollection.create(:name => params["new_collection"]['new_collection_name'])
                end

                # if we have an AssetCollection then add it to the params hash of collections to be
                # assigned this Asset
                if the_collection
                  unless params["gluttonberg::asset"]['collection_ids'].include?(the_collection.id.to_s)
                    params["gluttonberg::asset"]['collection_ids'] << the_collection.id.to_s
                  end
                end
              end
            end
          end
        end

        if @asset.update_attributes(params["gluttonberg::asset"])
          redirect(slice_url(:asset, @asset))
        else
          prepare_to_edit
          render :new
        end
      end
      
      def destroy
        @asset.destroy
        redirect(slice_url(:library))
      end
      
      private
      
      def find_asset
        @asset = Asset.get(params[:id])
        raise NotFound unless @asset
      end
      
      def prepare_to_edit
        @dialects = Dialect.all
        @locales = Locale.all
        @collections = AssetCollection.all
      end
    end
  end
end