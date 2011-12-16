class NamespaceAlchemyModels < ActiveRecord::Migration
	def change
		rename_table :attachments,					:alchemy_attachments
		rename_table :cells,								:alchemy_cells
		rename_table :contents,							:alchemy_contents
		rename_table :elements,							:alchemy_elements
		rename_table :elements_pages, 			:alchemy_elements_alchemy_pages
		rename_table :essence_audios, 			:alchemy_essence_audios
		rename_table :essence_dates,				:alchemy_essence_dates
		rename_table :essence_files,				:alchemy_essence_files
		rename_table :essence_flashes,			:alchemy_essence_flashes
		rename_table :essence_htmls,				:alchemy_essence_htmls
		rename_table :essence_pictures,			:alchemy_essence_pictures
		rename_table :essence_richtexts,		:alchemy_essence_richtexts
		rename_table :essence_texts,				:alchemy_essence_texts
		rename_table :essence_videos,				:alchemy_essence_videos
		rename_table :folded_pages,					:alchemy_folded_pages
		rename_table :languages,						:alchemy_languages
		rename_table :pages,								:alchemy_pages
		rename_table :pictures, 						:alchemy_pictures
		rename_table :users,								:alchemy_users
	end
end
