﻿using AutoMapper;
using reciWebApp.Data.IRepositories;
using reciWebApp.Data.Models;
using reciWebApp.DTOs.CategoryDTOs;
using reciWebApp.DTOs.PostDTOs;
using reciWebApp.Services.Interfaces;
using reciWebApp.Services.Utils;

namespace reciWebApp.Services
{
    public class PostService : IPostService
    {
        private readonly IRepositoryManager _repoManager;
        private readonly IConfiguration _configuration;
        private readonly IMapper _mapper;
        public PostService(IRepositoryManager repoManager, IConfiguration config, IMapper mapper)
        {
            _repoManager = repoManager;
            _configuration = config;
            _mapper = mapper;
        }
        public bool CheckPostAuthority(int userId, string postId)
        {
            bool checkAuthority = true;
            if (!(_repoManager.User.GetUserById(userId)).Role.Equals("admin"))
            {
                var post = _repoManager.Post.GetPostById(postId);
                if (userId != post.UserId)
                {
                    checkAuthority = false;
                }
            }
            return checkAuthority;
        }

        public ShowPostDTO GetPostInfo(ShowPostDTO showPostDTO)
        {
            var listPostCategories = _repoManager.PostCategory.GetPostCategoriesByPostId(showPostDTO.Id);
            List<Category> categories = new List<Category>();
            foreach (var postCategory in listPostCategories)
            {
                categories.Add(_repoManager.Category.GetCategoryById(postCategory.CategoryId));
            }
            showPostDTO.ListCategories = _mapper.Map<List<ShowCategoryDTO>>(categories);
            showPostDTO.Continents = _repoManager.RecipeRegion.GetRecipeRegionsById(showPostDTO.RecipeRegionId).Continents;
            showPostDTO.Method = _repoManager.CookingMethod.GetCookingMethodById(showPostDTO.CookingMethodId).Method;
            showPostDTO.UserName = _repoManager.User.GetUserById(showPostDTO.UserId).Name;
            showPostDTO.AverageRating = _repoManager.UserInteract.GetAverageRating(showPostDTO.Id);
            return showPostDTO;
        }

        public IEnumerable<ShowPostDTO> SortPostByCondition(List<ShowPostDTO> posts, string? condition)
        {
            IEnumerable<ShowPostDTO> sortPosts = posts;
            if (condition.Equals("Newest"))
            {
                sortPosts = posts.OrderByDescending(x => x.CreateDate);
            }
            else if (condition.Equals("Oldest"))
            {
                sortPosts = posts.OrderBy(x => x.CreateDate);
            }
            else if (condition.Equals("Popularity"))
            {
                sortPosts = posts.OrderByDescending(x => x.AverageRating);
            }
            return sortPosts;
        }
    }
}