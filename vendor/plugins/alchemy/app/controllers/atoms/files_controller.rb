class Atoms::FilesController < ApplicationController
  
  layout 'alchemy'
  
  filter_access_to :all
  
  def edit
    @atom = Atom.find(params[:id])
    @file_atom = @atom.atom
    render :layout => false
  end
  
  def update
    @atom = Atom.find(params[:id])
    @atom.atom.update_attributes(params[:atom])
    render :update do |page|
      page << "wa_overlay.close(); reloadPreview()"
    end
  end
  
  def assign
    @atom = Atom.find_by_id(params[:id])
    @wa_file = File.find_by_id(params[:wa_file_id])
    @atom.atom.wa_file = @wa_file
    @atom.atom.save
    @atom.save
    render :update do |page|
      page.replace "wa_file_#{@atom.id}", :partial => "atoms/atom_file_editor", :locals => {:atom => @atom, :options => params[:options]}
      page << "reloadPreview();wa_overlay.close()"
    end
  end
  
end