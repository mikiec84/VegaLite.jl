################################################################################
#  Save to file functions
################################################################################


################   FileIO integration   ##############################

"""
    save(filename::AbstractString, v::VLSpec{:plot})

Save the plot ``v`` using the FileIO package, guessing the format type with
the file ``filename`` if it exists, or if not with file extension of ``filename``.
"""
save(f::File{format"PDF"}, v::VLSpec{:plot}) =
  open(s -> show(s.io, MIME"application/pdf"(), v), f, "w")

save(f::File{format"PNG"}, v::VLSpec{:plot}) =
  open(s -> show(s.io, MIME"image/png"()      , v), f, "w")

save(f::File{format"JPEG"}, v::VLSpec{:plot}) =
  open(s -> show(s.io, MIME"image/jpeg"()     , v), f, "w")

save(f::File{format"SVG"}, v::VLSpec{:plot}) =
  open(s -> show(s.io, MIME"image/svg+xml"()  , v), f, "w")


################   saving functions by format   ########################

"""
    pdf(filename::AbstractString, v::VLSpec{:plot})

Save the plot ``v`` as a pdf file with name ``filename``.
"""
pdf(f::AbstractString, v::VLSpec{:plot}) =
  open(s -> show(s, MIME"application/pdf"(), v), f, "w")


"""
    png(filename::AbstractString, v::VLSpec{:plot})

Save the plot ``v`` as a png file with name ``filename``.
"""
png(f::AbstractString, v::VLSpec{:plot}) =
  open(s -> show(s, MIME"image/png"()      , v), f, "w")


"""
    jpg(filename::AbstractString, v::VLSpec{:plot})

Save the plot ``v`` as a jpeg file with name ``filename``.
"""
jpg(f::AbstractString, v::VLSpec{:plot}) =
  open(s -> show(s, MIME"image/jpeg"()     , v), f, "w")


"""
  svg(filename::AbstractString, v::VLSpec{:plot})

Save the plot ``v`` as a svg file with name ``filename``.
"""
svg(f::AbstractString, v::VLSpec{:plot}) =
  open(s -> show(s, MIME"image/svg+xml"()  , v), f, "w")
