SRC_DIR=        src

SRC=		$(SRC_DIR)/main.c \
			$(SRC_DIR)/algo.c \
			$(SRC_DIR)/parser.c \

OBJ=            $(SRC: .c=.o)

CFLAGS=       	-L lib/my/ -lmy -I include -W -Wall -Wextra

NAME=           bsq

all:            $(NAME)

$(NAME):        $(OBJ)
		make re -C lib/my/
		gcc -o $(NAME) $(SRC) $(CFLAGS)

clean:
		rm -f *.o

fclean:         clean
		rm -f $(NAME)

re:             fclean all
