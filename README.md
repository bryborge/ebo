# Easy Bake Oven (EBO)

## 🚀 About the Project

The [Easy-Bake Oven](https://en.wikipedia.org/wiki/Easy-Bake_Oven) is a toy that was first introduced to the market in
1964. I didn't actually know that until I started thinking about what to name this project. But it seems so fitting,
right?  Easy-Bake Oven is a functional toy used to bake things like biscuits and cookies.  Ebo is a functional "toy"
that I use to "bake" custom golden images.  Unlike confectionaries however, the images are not tasty. But the process is
satisfying all the same.

### 📖 Definitions

*   Golden Image

    > _A golden image is a base image on top of which developers can build applications, letting them focus on the
    > application itself instead of system dependencies and patches. A typical golden image includes common system,
    > logging, and monitoring tools, recent security patches, and application dependencies._
    >
    > -- Hashicorp ([Source article](https://learn.hashicorp.com/tutorials/packer/golden-image-with-hcp-packer))

## 💽 Versioning

Golden images in this project use Semantic Versioning ([SemVer](https://semver.org/)). Versions are defined in a file
called `version.pkrvars.hcl` located at each OS distro's base directory.

## 🔧 Tooling

*   [Ansible](https://www.ansible.com/) - Machine provisioning automation platform.
*   [Packer](https://www.packer.io/) - Identical machine images for multiple platforms from a single source 
    configuration.

## 💻 Useful Commands

*   Validate all Ubuntu builds.

    ```sh
    packer validate -var-file="../../version.pkrvars.hcl" .
    ```

*   Validate an Ubuntu 22.04 Proxmox build.

    ```sh
    packer validate \
      -only=ubuntu.proxmox.22.04 \
      -var-file="../../version.pkrvars.hcl" .
    ```

*   Build an Ubuntu 22.04 AWS golden image.

    ```sh
    packer build \
      -only=ubuntu.amazon-ebs.22.04 \
      -var "distro_short_name=jammy" \
      -var-file="../../version.pkrvars.hcl" .
    ```

*   Build an Ubuntu 20.04 Proxmox golden image.

    ```sh
    packer validate \
      -only=ubuntu.proxmox.20.04 \
      -var "distro_short_name=focal" \
      -var-file="../../version.pkrvars.hcl" .
    ```

*   Query for a specific AMI's information

    ```sh
    aws ssm get-parameters --names \
      /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id
    ```

## ⭐ License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## 📚 Further Reading

*   [Hashicorp Packer Tutorial](https://learn.hashicorp.com/tutorials/packer/golden-image-with-hcp-packer) - Official Packer tutorial.
*   [Ubuntu Image Locator](https://cloud-images.ubuntu.com/locator/) - Ubuntu cloud image location lookup.
