class Api::UploadsController < Api::BaseController
  def create
    unless params[:file].present?
      return render json: { error: "No file provided" }, status: :unprocessable_entity
    end

    blob = ActiveStorage::Blob.create_and_upload!(
      io: params[:file].tempfile,
      filename: params[:file].original_filename,
      content_type: params[:file].content_type
    )

    # Validate file size (5MB limit)
    if blob.byte_size > 5.megabytes
      blob.purge
      return render json: { error: "File too large (max 5MB)" }, status: :unprocessable_entity
    end

    # Validate content type
    unless blob.content_type.in?(%w[image/jpeg image/png image/webp image/gif])
      blob.purge
      return render json: { error: "Invalid file type" }, status: :unprocessable_entity
    end

    render json: {
      url: url_for(blob),
      filename: blob.filename.to_s,
      content_type: blob.content_type,
      byte_size: blob.byte_size
    }
  end
end
