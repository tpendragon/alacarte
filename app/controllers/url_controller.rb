class UrlController < ApplicationController
  before_filter :module_types
  before_filter :current_page
  before_filter :current_guide
  before_filter :current_tutorial
  layout 'tool'

 def edit_url
     @ecurrent = 'current'
     begin
        @mod = find_mod(params[:id], "UrlResource")
     rescue ActiveRecord::RecordNotFound
        redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
     else 
      session[:mod_id] = @mod.id
      session[:mod_type] = @mod.class
     end
end
 


def update_url
  params[:mod][:existing_link_attributes] ||= {} 
  params[:mod][:new_link_attributes] ||= {} 
  @mod = find_mod(params[:id], "UrlResource")
  @mod.update_attributes(params[:mod]) 
    if @mod.save 
       redirect_to :controller => 'module', :action => "preview" , :id =>@mod.id, :type=> @mod.class
    else 
      render :action => 'edit_url' , :mod => @mod
    end
  end

def copy_url
    begin
     @old_mod = find_mod(params[:id], "UrlResource")
    rescue Exception 
     redirect_to :controller => 'module', :action => 'index', :list=> 'mine'
   else
      @mod = @old_mod.clone
      @mod.global = false
     if @mod.save
       @mod.label =  @old_mod.label+'-copy'
        @mod.links << @old_mod.links.collect{|l| l.clone if l}
        create_and_add_resource(@user,@mod)
          flash[:notice] = "Saved as #{@mod.label}"
        redirect_to  :controller => 'module', :action => "edit_content" , :id =>@mod.id, :type=> @mod.class
     end
   end  
 end


end
