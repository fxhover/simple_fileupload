Simple Fileupload
======

A rails simple file upload gem

Installation
============

    gem "simple_fileupload"

And run bundle install. 

Use
====
    fileupload = SimpleFileupload.new(upload_path: upload_path, max_size: allow_max_size, type: allow_type, random_dir: whether_randdom_dir)

    Arguments hash:
        upload_path: file upload path, default is Rails.root + '/data'
        max_size: allow max file size
        type: if it is 'image',check upload file whether it is a image
        random_dir: if it is true, randomly generated upload path dir in (0..9) + ('a'..'z'), default is false

    upload_info = fileupload.upload params[:file]

    puts upload_info
    #=> like {file_name: file_name, real_file_name: real_file_name, file_size: file_size, upload_path: @upload_path, file_full_path: file_path, mime_type: mime_type}

    Return hash:
        file_name: upload file name
        real_file_name: uploaded real file name
        file_size: upload file byte size
        upload_path: upload file directory
        file_full_path: uploaded file full path, include upload_path and real_file_name
        mime_type: uploaded file mime type
Acknowledgements
================
Copyright fxhover, released under the MIT License.

