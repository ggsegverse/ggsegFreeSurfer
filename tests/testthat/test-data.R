cortical_names <- c("dkt", "destrieux")

for (nm in cortical_names) {
  atlas <- do.call(nm, list())

  describe(paste(nm, "atlas"), {
    it("is a ggseg_atlas", {
      expect_s3_class(atlas, "ggseg_atlas")
      expect_s3_class(atlas, "cortical_atlas")
    })

    it("is valid", {
      expect_true(ggseg.formats::is_ggseg_atlas(atlas))
    })

    it("has brain_polygons 2D geometry", {
      expect_true(ggseg.formats::is_atlas_polygon(atlas))
    })

    it("has a named palette", {
      pal <- ggseg.formats::atlas_palette(atlas)
      expect_type(pal, "character")
      expect_named(pal)
    })

    it("exposes vertices via atlas_vertices", {
      verts <- ggseg.formats::atlas_vertices(atlas)
      expect_s3_class(verts, "ggseg_vertices")
    })

    it("renders with ggseg", {
      skip_if_not_installed("ggseg")
      skip_if_not_installed("vdiffr")
      vdiffr::expect_doppelganger(
        paste0(nm, "-2d"),
        ggseg::brain_test_plot(atlas)
      )
    })

    it("renders with ggseg3d", {
      skip_if_not_installed("ggseg3d")
      skip_if_not_installed("ggseg.meshes")
      p <- ggseg3d::ggseg3d(atlas = atlas)
      expect_s3_class(
        p,
        c("plotly", "htmlwidget")
      )
    })
  })
}

subcortical_names <- c(
  "hcpa",
  "thalamus",
  "hippoamyg",
  "brainstem",
  "hypothalamus"
)

for (nm in subcortical_names) {
  atlas <- do.call(nm, list())

  describe(paste(nm, "atlas"), {
    it("is a ggseg_atlas", {
      expect_s3_class(atlas, "ggseg_atlas")
      expect_s3_class(atlas, "subcortical_atlas")
    })

    it("is valid", {
      expect_true(ggseg.formats::is_ggseg_atlas(atlas))
    })

    it("has brain_polygons 2D geometry", {
      expect_true(ggseg.formats::is_atlas_polygon(atlas))
    })

    it("has a named palette", {
      pal <- ggseg.formats::atlas_palette(atlas)
      expect_type(pal, "character")
      expect_named(pal)
    })

    it("exposes meshes via atlas_meshes", {
      meshes <- ggseg.formats::atlas_meshes(atlas)
      expect_s3_class(meshes, "ggseg_meshes")
    })

    it("renders with ggseg3d", {
      skip_if_not_installed("ggseg3d")
      skip_if_not_installed("ggseg.meshes")
      p <- ggseg3d::ggseg3d(atlas = atlas)
      expect_s3_class(
        p,
        c("plotly", "htmlwidget")
      )
    })
  })
}
