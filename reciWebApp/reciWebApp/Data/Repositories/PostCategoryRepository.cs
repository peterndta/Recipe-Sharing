﻿using reciWebApp.Data.IRepositories;
using reciWebApp.Data.Models;

namespace reciWebApp.Data.Repositories
{
    public class PostCategoryRepository : RepositoryBase<PostCategory>, IPostCategoryRepository
    {
        public PostCategoryRepository(ReciContext reciContext) : base(reciContext)
        {
        }

        public void CreatePostCategory(PostCategory postCategory)
        {
            Create(postCategory);
        }

        public List<PostCategory> GetPostCategoriesByPostId(string id)
        {
            return GetByCondition(x => x.PostId.Equals(id)).ToList();
        }

        public List<PostCategory?> GetPostCategoriesByCategory(List<Category?> categories)
        {
            var postCategories = GetAllPostCategories();
            List<PostCategory> result = new List<PostCategory>();
            if (postCategories.Any() && categories.Count > 0)
            {
                foreach (var category in categories)
                {
                    result.AddRange(postCategories.Where(x => x.CategoryId == category.Id).ToList());
                }
                return result;
            }
            return postCategories;
        }

        public List<PostCategory?> GetAllPostCategories()
        {
            return GetAll().ToList();
        }
    }
}
