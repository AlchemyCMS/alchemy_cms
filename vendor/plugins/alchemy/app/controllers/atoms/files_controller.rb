class Atoms::FilesController < ApplicationController
  
  layout 'alchemy'
  
  filter_access_to :all
  
  def edit
    @atom = WaAtom.find(params[:id])
    @file_atom = @atom.atom
    render :layout => false
  end
  
  def update
    @wa_atom = WaAtom.find(params[:id])
    @wa_atom.atom.update_attributes(params[:atom])
    render :update do |page|
      page << "wa_overlay.close(); reloadPreview()"
    end
  end
  
  def assign
    @wa_atom = WaAtom.find_by_id(params[:id])
    @wa_file = File.find_by_id(params[:wa_file_id])
    @wa_atom.atom.wa_file = @wa_file
    @wa_atom.atom.save
    @wa_atom.save
    render :update do |page|
      page.replace "wa_file_#{@wa_atom.id}", :partial => "wa_atoms/wa_atom_file_editor", :locals => {:wa_atom => @wa_atom, :options => params[:options]}
      page << "reloadPreview();wa_overlay.close()"
    end
  end
  
end