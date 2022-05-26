#include <stdio.h>
#include <stdlib.h>
#include <string.h>
typedef struct _Cat {
        struct _Cat *next;
        char name[255];
        int color;
        char can_climb;
} Cat;
typedef struct _Dog {
        struct _Dog *next;
        char name[255];
        int color;
        char can_swim;
} Dog;
Cat *create_cat(char *name, int color, char can_climb);
void insert_cat(Cat *cat);
void delete_cat(Cat *cat);
Dog *create_dog(char *name, int color, char can_swim);
void insert_dog(Dog *dog);
void delete_dog(Dog *dog);
Cat *cats;
Dog *dogs;
int main()
{
        printf("\n--------------EXAMPLE------------------\n");
        Cat *cat1 = create_cat("Cat1", 2, 0);
        Cat *cat2 = create_cat("Cat2", 3, 1);
        Cat *cat3 = create_cat("Cat3", 4, 0);
        Cat *cat4 = create_cat("Cat4", 2, 0);
        cats = NULL;
        insert_cat(cat1);
        insert_cat(cat2);
        insert_cat(cat3);
        insert_cat(cat4);
        delete_cat(cat4);
        Cat *catptr = cats;
        while (catptr) {
                printf("\n%s", catptr->name);
                catptr = catptr->next;
        }
        printf("\n");
        Dog *dog1 = create_dog("Dog1", 2, 0);
        Dog *dog2 = create_dog("Dog2", 3, 1);
        Dog *dog3 = create_dog("Dog3", 4, 0);
        Dog *dog4 = create_dog("Dog4", 2, 0);
        dogs = NULL;
        insert_dog(dog1);
        insert_dog(dog2);
        insert_dog(dog3);
        insert_dog(dog4);
        delete_dog(dog4);
        Dog *dogptr = dogs;
        while (dogptr) {
                printf("\n%s", dogptr->name);
                dogptr = dogptr->next;
        }
        printf("\n");
        return 0;
}
Cat *create_cat(char *name, int color, char can_climb) {
        Cat *cat = (Cat *)malloc(sizeof(Cat));
        cat->next = NULL;
        strcpy(cat->name, name);
        cat->color = color;
        cat->can_climb = can_climb;

		return cat;
}
void insert_cat(Cat *cat)
{
        if (cat == NULL) return;
        cat->next = NULL;
        if (cats == NULL) {
                cats = cat;
        }
        else {
                Cat *catptr = cats;
                while (catptr->next) {
                        catptr = catptr->next;
                }
                catptr->next = cat;
        }
}
void delete_cat(Cat *cat)
{
        if (cats == NULL || cat == NULL) {
                return;
        }
        Cat *ptr = cats;
        if (ptr == cat) {
                ptr = ptr->next;
                free(cat);
        }
        while (ptr->next) {
                if (ptr->next == cat) {
                        ptr->next = ptr->next->next;
                        free(cat);
                        break;
                }
                ptr = ptr->next;
        }
}
Dog *create_dog(char *name, int color, char can_swim) {
        Dog *dog = (Dog *)malloc(sizeof(Dog));
        dog->next = NULL;
        strcpy(dog->name, name);
        dog->color = color;
        dog->can_swim = can_swim;
		return dog;
}
void insert_dog(Dog *dog)
{
        if (dog == NULL) return;
        dog->next = NULL;
        if (dogs == NULL) {
                dogs = dog;
        }
        else {
                Dog *dogptr = dogs;
                while (dogptr->next) {
                        dogptr = dogptr->next;
                }
                dogptr->next = dog;
        }
}
void delete_dog(Dog *dog)
{
        if (dogs == NULL || dog == NULL) {
                return;
        }
        Dog *ptr = dogs;
        if (ptr == dog) {
                ptr = ptr->next;
                free(dog);
        }
        while (ptr->next) {
                if (ptr->next == dog) {
                        ptr->next = ptr->next->next;
                        free(dog);
                        break;
                }
                ptr = ptr->next;
        }
}