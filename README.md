# Synthetic Curves Multiview Dataset
<img src="synthcurves-dataset-snapshot.png" width="215" height="84" />

Synthetic Curves Dataset

- 40 curves:Lines, circles, ellipses, helices, and another space curve with complicated torsion.
- Cameras in two turntable geometries:
  - Video camera configuration (small focal length)
  - Micro-CT configuration (objects lying between optical center and CCD)
- Space curves are sampled and projected to subpixel edgels (tangent and other differential-geometric information) to generate a video. The differential geometry arises by projecting the 3D measurements according to "Multiview Differential geometry of Curves", IJCV 2016.
- Each image is 500x400px


## Download
[Git LFS](https://git-lfs.github.com) (Large File Storage) is *required* for
downloading and uploading from/to this dataset repository.  Otherwise, you will
get tiny text files instead of actual big files.

Install [Git LFS](https://git-lfs.github.com) and then, after cloning the
repository, run
```
  git lfs pull
```
Thanks to Irina Nurutdinova, TU Berlin, for testing this out.

## Files

```
misc/

misc/old
```

## Version

Dataset produced and tested in C++ with the [VXD][http://github.com/rfabbri/vxd] library
under Mac OS X.

## Authors

[Ricardo Fabbri](http://rfabbri.github.io) built the dataset.
Fostered by Benjamin Kimia, Brown University.

## Citing the dataset

Please cite the original paper this dataset appeared in:

```bibtex
@inproceedings{Fabbri:Giblin:Kimia:ECCV12,
    Author         = {Ricardo Fabbri and Peter J. Giblin and Benjamin B. Kimia},
    Booktitle      = {Proceedings of the IEEE European Conference in Computer Vision},
    Crossref       = {ECCV2012},
    Title          = {Camera Pose Estimation Using First-Order Curve Differential Geometry},
    Year           = {2012}
}

@proceedings{ECCV2012,
  title     = {Computer Vision - ECCV 2012, 12th European Conference on
               Computer Vision, Firenze, Italy, October 7-13,
               2012, Proceedings},
  booktitle = {12th European Conference on
               Computer Vision, Firenze, Italy, October 7-13,
               2012},
  publisher = {Springer},
  series    = {Lecture Notes in Computer Science},
  year      = {2012}
}

```

## Credits

We also acknowledge ICERM/Brown University, FAPERJ/Brazil and NSF support.

## Links

Images and explanations of this ground truth are provided in:
http://Multiview-3d-Drawing.sf.net

