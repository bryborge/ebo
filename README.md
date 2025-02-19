# Easy Bake Oven (EBO)

## 🚀 About the Project

The [Easy-Bake Oven](https://en.wikipedia.org/wiki/Easy-Bake_Oven) is a toy that was first introduced to the market in
1964. I didn't actually know that until I started thinking about what to name this project. But it seems so fitting,
right?  Easy-Bake Oven is a functional toy used to bake things like biscuits and cookies.  Ebo is a functional "toy"
that I use to "bake" custom golden images.  Unlike confectionaries however, the images are not tasty. But the process is
satisfying all the same.

## Useful Commands

```sh
docker build -t bryborge/ebo:v1 .
```

```sh
docker volume create ebo-vol
```

```sh
docker run -it \
  --privileged \
  --name ebo \
  --mount type=bind,src=$(pwd),dst=/home/souschef/ebo \
  --mount type=bind,src=/dev,dst=/dev \
bryborge/ebo:v1
```

Or, if the container is already created but not running, ...

```sh
docker start -i ebo
```

Which is the same as ...

```sh
docker start ebo
docker attach ebo
```

```sh
docker rm ebo
docker volume rm ebo-vol
docker rmi bryborge/ebo:v1
```
