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
    }
}
