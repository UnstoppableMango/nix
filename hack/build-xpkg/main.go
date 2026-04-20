package main

import (
	"archive/tar"
	"bytes"
	"errors"
	"flag"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/google/go-containerregistry/pkg/v1/mutate"
	"github.com/google/go-containerregistry/pkg/v1/tarball"
)

func main() {
	var (
		baseTar    = flag.String("base-tar", "", "Path to the base controller image tarball")
		packageDir = flag.String("package-dir", "", "Path to the upstream package directory")
		output     = flag.String("output", "", "Path to the output package tarball")
	)

	flag.Parse()

	if *baseTar == "" || *packageDir == "" || *output == "" {
		flag.Usage()
		os.Exit(2)
	}

	if err := run(*baseTar, *packageDir, *output); err != nil {
		fmt.Fprintf(os.Stderr, "build-xpkg: %v\n", err)
		os.Exit(1)
	}
}

func run(baseTar, packageDir, output string) error {
	image, err := tarball.ImageFromPath(baseTar, nil)
	if err != nil {
		return fmt.Errorf("load base image: %w", err)
	}

	layerPath, err := buildPackageLayer(packageDir)
	if err != nil {
		return err
	}
	defer os.Remove(layerPath)

	layer, err := tarball.LayerFromFile(layerPath)
	if err != nil {
		return fmt.Errorf("load package layer: %w", err)
	}

	image, err = mutate.AppendLayers(image, layer)
	if err != nil {
		return fmt.Errorf("append package layer: %w", err)
	}

	file, err := os.Create(output)
	if err != nil {
		return fmt.Errorf("create output tarball: %w", err)
	}
	defer file.Close()

	if err := tarball.Write(nil, image, file); err != nil {
		return fmt.Errorf("write package tarball: %w", err)
	}

	return nil
}

func buildPackageLayer(packageDir string) (string, error) {
	packageYAML, err := buildPackageStream(packageDir)
	if err != nil {
		return "", err
	}

	file, err := os.CreateTemp("", "provider-upjet-cloudflare-package-*.tar")
	if err != nil {
		return "", fmt.Errorf("create package layer tarball: %w", err)
	}
	defer file.Close()

	writer := tar.NewWriter(file)
	header := &tar.Header{
		Name:       "package.yaml",
		Mode:       0o644,
		Size:       int64(len(packageYAML)),
		ModTime:    time.Unix(1, 0).UTC(),
		AccessTime: time.Unix(1, 0).UTC(),
		ChangeTime: time.Unix(1, 0).UTC(),
	}

	if err := writer.WriteHeader(header); err != nil {
		return "", fmt.Errorf("write package header: %w", err)
	}
	if _, err := writer.Write(packageYAML); err != nil {
		return "", fmt.Errorf("write package content: %w", err)
	}
	if err := writer.Close(); err != nil {
		return "", fmt.Errorf("close package tar writer: %w", err)
	}

	return file.Name(), nil
}

func buildPackageStream(packageDir string) ([]byte, error) {
	metaFile := filepath.Join(packageDir, "crossplane.yaml")
	if _, err := os.Stat(metaFile); err != nil {
		return nil, fmt.Errorf("stat crossplane.yaml: %w", err)
	}

	files := []string{metaFile}
	err := filepath.WalkDir(packageDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() || path == metaFile {
			return nil
		}

		ext := strings.ToLower(filepath.Ext(path))
		if ext != ".yaml" && ext != ".yml" {
			return nil
		}

		files = append(files, path)
		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("walk package dir: %w", err)
	}

	sort.Strings(files[1:])

	var buf bytes.Buffer
	for _, path := range files {
		content, err := os.ReadFile(path)
		if err != nil {
			return nil, fmt.Errorf("read %s: %w", path, err)
		}

		trimmed := bytes.TrimSpace(content)
		if len(trimmed) == 0 {
			continue
		}

		if buf.Len() == 0 {
			buf.WriteString("---\n")
		} else {
			buf.WriteString("\n---\n")
		}
		buf.Write(trimmed)
		buf.WriteByte('\n')
	}

	if buf.Len() == 0 {
		return nil, errors.New("package directory did not contain any YAML content")
	}

	return buf.Bytes(), nil
}
