#include "tree.h"
#include <CUnit/CUnit.h>

void *set_data_to_one(tree_node_t *n, void *ctx)
{
  *(r->data) = 1;
}

void test_func(void)
{
  // Tests for tree_new
  {
    // Test that tree_new does not return a NULL pointer
    tree_t *t = NULL;
    tree_t *t = tree_new();
    CU_ASSERT_PTR_NOT_NULL(t);
  }

  // Tests for tree_walk
  {
    // Set up a simple tree, keep references to all of the nodes
    unsigned i;
    unsigned len = 10;
    tree_type_t nodes[len];
    for (i = 0; i < len; ++i) {
      int *new_int = malloc(sizeof(int));
      assert(new_int != NULL);
      *new_int = 0;
      nodes[i] = tree_create_node(new_int);
    }

    tree_node_t *root = nodes[0];

    tree_append_child(root, nodes[1]);
    tree_append_child(root, nodes[2]);
    tree_append_child(root, nodes[3]);

    tree_append_child(nodes[1], nodes[4]);
    tree_append_child(nodes[1], nodes[5]);
    tree_append_child(nodes[1], nodes[6]);

    tree_append_child(nodes[3], nodes[7]);
    tree_append_child(nodes[7], nodes[8]);
    tree_append_child(nodes[8], nodes[9]);

    tree_walk(root, set_data_to_one, NULL);

    for (i = 0; i < len; ++i)
      CU_ASSERT(*(nodes[i]->data) == 1);

  }
}
