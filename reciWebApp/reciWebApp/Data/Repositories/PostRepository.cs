﻿using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using Microsoft.VisualBasic;
using reciWebApp.Data.IRepositories;
using reciWebApp.Data.Models;
using reciWebApp.Data.Pagination;
using reciWebApp.Data.Repositories.Extensions;
using reciWebApp.DTOs.PostDTOs;
using reciWebApp.DTOs.UserDTOs;
using reciWebApp.Services.Commons;
using reciWebApp.Services.Utils;

namespace reciWebApp.Data.Repositories
{
    public class PostRepository : RepositoryBase<Post>, IPostRepository
    {
        public PostRepository(ReciContext reciContext) : base(reciContext)
        {
        }

        public void CreatePost(Post post)
        {
            Create(post);
        }

        public void DeletePost(Post post)
        {
            Delete(post);
        }

        public void UpdatePost(Post post)
        {
            Update(post);
        }

        public Post? GetPostById(string id)
        {
            return GetByCondition(x => x.Id.Equals(id) && x.Status == PostStatus.Active).FirstOrDefault();
        }

        public async Task<Post?> GetActivePostByIdAsync(string id)
        {
            return await GetByCondition(x => x.Id.Equals(id) && x.Status == PostStatus.Active).SingleOrDefaultAsync();
        }

        public async Task<List<Post>> GetActivePostByUserIdAsync(int id)
        {
            return await GetByCondition(x => x.UserId == id && x.Status == PostStatus.Active).ToListAsync();
        }

        public async Task<List<Post>?> GetAllPostsByUserIdAsync(string? name, int userId)
        {
            var posts = await GetByCondition(x => x.UserId == userId && x.Status == PostStatus.Active)
                .FilterPostByName(_reciContext, name)
                .ToListAsync();
            return posts;
        }

        public List<Post> GetPostsByPostCategories(List<PostCategory> postCategories)
        {
            var posts = GetByCondition(x => x.Status == PostStatus.Active).ToList();
            var result = new List<Post>();
            if (posts.Count > 0 && postCategories.Count > 0)
            {
                postCategories.DistinctBy(x => x.PostId);
                foreach (var postCategory in postCategories)
                {
                    var post = GetPostById(postCategory.PostId);
                    if (post != null)
                    {
                        result.Add(post);
                    }
                }              
            }
            return result;
        }

        public List<Post> GetPostsByCookingMethods(List<int> cookingMethodsId)
        {
            var posts = GetByCondition(x => x.Status == PostStatus.Active).ToList();
            var result = new List<Post>();
            if (posts.Count > 0 && cookingMethodsId.Count > 0)
            {
                foreach (var cookingMethodId in cookingMethodsId)
                {
                    var validResult = posts.Where(x => x.CookingMethodId == cookingMethodId).ToList();
                    if (validResult != null)
                    {
                        result.AddRange(validResult);
                    }
                }
            }
            return result;
        }

        public List<Post> GetPostsByRecipeRegions(List<RecipeRegion> recipeRegions)
        {
            var posts = GetByCondition(x => x.Status == PostStatus.Active).ToList();
            var result = new List<Post>();
            if (posts.Count > 0 && recipeRegions.Count > 0)
            {
                foreach (var recipeRegion in recipeRegions)
                {
                    result.AddRange(GetByCondition(x => x.RecipeRegionId == recipeRegion.Id).ToList());
                }
            }
            return result;
        }

        public List<Post> GetPostsByUses(List<Use> uses)
        {
            var posts = GetByCondition(x => x.Status == PostStatus.Active).ToList();
            var result = new List<Post>();
            if (posts.Count > 0 && uses.Count > 0)
            {
                foreach (var use in uses)
                {
                    result.AddRange(GetByCondition(x => x.UsesId == use.Id).ToList());
                }
            }
            return result;
        }

        public List<ShowPostDTO> SortPostByCondition(List<ShowPostDTO> posts, string? condition)
        {
            if (condition.Equals(SortTypes.Newest))
            {
                posts = posts.OrderByDescending(x => x.CreateDate).ToList();
            }
            else if (condition.Equals(SortTypes.Oldest))
            {
                posts = posts.OrderBy(x => x.CreateDate).ToList();
            }
            else if (condition.Equals(SortTypes.Popularity))
            {
                posts = posts.OrderByDescending(x => x.AverageRating).ToList();
            }
            return posts;
        }

        public async Task<List<Post>?> GetPostByUserInteractsAsync(List<UserInteract> userInteracts, string? name)
        {
            var result = new List<Post>();
            foreach (var userInteract in userInteracts)
            {
                var post = GetPostById(userInteract.PostsId);
                if (post != null)
                {
                    result.Add(post);
                }
            }
            if (name != null)
            {
                return SearchByName(result, name);
            }
            return result;
        }

        public async Task<List<Post>?> GetPostsFilterByMethodsAsync(PostParams postParams)
        {
            var posts = GetByCondition(x => x.Status == PostStatus.Active).ToList();
            if (postParams.PostsByCookingMethods != null)
            {
                posts = (posts.Intersect(postParams.PostsByCookingMethods)).ToList();
            }

            if (postParams.Name != null)
            {
                return SearchByName(posts, postParams.Name);
            }
            return posts;
        }

        public async Task<List<Post>?> GetPostsFilterByCategoriesAsync(PostParams postParams)
        {
            var posts = GetByCondition(x => x.Status == PostStatus.Active).ToList();
            if (postParams.PostsByCategories != null)
            {
                posts = posts.Intersect(postParams.PostsByCategories).ToList();
            }

            if (postParams.Name != null)
            {
                return SearchByName(posts, postParams.Name);
            }
            return posts;
        }

        public async Task<List<Post>?> GetPostsFilterByUsesAndRegionsAsync(PostParams postParams)
        {
            var posts = GetByCondition(x => x.Status == PostStatus.Active).ToList();
            if (postParams.PostsRecipeRegions != null && postParams.PostsByUses != null)
            {
                posts = (posts.Intersect(postParams.PostsRecipeRegions)).ToList();
                posts = posts.Union(postParams.PostsByUses).DistinctBy(x => x.Id).ToList();
            }
            else if (postParams.PostsRecipeRegions != null && postParams.PostsByUses == null)
            {
                posts = (posts.Intersect(postParams.PostsRecipeRegions)).ToList();
            }
            else if (postParams.PostsRecipeRegions == null && postParams.PostsByUses != null)
            {
                posts = posts.Intersect(postParams.PostsByUses).ToList();
            }
            if (postParams.Name != null)
            {
                return SearchByName(posts, postParams.Name);
            }
            return posts;
        }

        public async Task<List<Post>?> GetPostByNameAsync(PostFilterByNameParams postFilterByNameParams)
        {
            return await GetByCondition(x => x.Status == PostStatus.Active).FilterPostByName(_reciContext, postFilterByNameParams.Search).ToListAsync();
        }

        public List<Post> GetPostByFoodCollection(List<FoodCollection> foodCollections)
        {
            var posts = GetByCondition(x => x.Status == PostStatus.Active).ToList();
            var result = new List<Post>();
            if (posts.Count > 0 && foodCollections.Count > 0)
            {
                foodCollections.DistinctBy(x => x.PostsId);
                foreach (var foodCollection in foodCollections)
                {
                    var post = GetPostById(foodCollection.PostsId);
                    if (post != null)
                    {
                        result.Add(post);
                    }
                }
            }
            return result;
        }

        public List<Post>? GetPostFilter(List<Post>? post, string? name)
        {
            var allPosts = GetByCondition(x => x.Status == PostStatus.Active).ToList();
            if (post != null)
            {
                allPosts = (allPosts.Intersect(post)).ToList();
            }

            if (name != null)
            {
                allPosts = SearchByName(allPosts, name);
            }
            return allPosts;
        }

        public async Task<List<Post>> GetBannedPostByUserIdAsync(int id)
        {
            var listBannedPost = GetByCondition(x => x.UserId == id && x.Status == PostStatus.Ban).ToListAsync();
            return await listBannedPost;
        }

        public List<Post> SearchByName(List<Post> posts, string name)
        {
            return posts.Where(x => x.Name.Contains(name, StringComparison.CurrentCultureIgnoreCase)).ToList();
        }

        public async Task<int> TotalPostsAsync()
        {
            return await GetByCondition(x => x.Status == PostStatus.Active).CountAsync();
        }

        public async Task<Post?> GetBannedPostByIdAsync(string id)
        {
            return await GetByCondition(x => x.Id.Equals(id) && x.Status == PostStatus.Ban).SingleOrDefaultAsync();
        }

        public IQueryable<Post> GetAllActivePost()
        {
            return GetByCondition(x => x.Status == 0);
        }

        public IQueryable<GetTopUserHaveMostPost> GetTopUserHaveMostPost(int topNumber)
        {
            var topUserIdHaveMostPost = GetByCondition(x => x.Status == 0)
                                        .GroupBy(x => x.UserId, y => y.Id)
                                        .Select(x => new GetTopUserHaveMostPost
                                        {
                                            UserId = x.Key,
                                            TotalPost = x.Count()
                                        })
                                        .OrderByDescending(x => x.TotalPost)
                                        .Take(topNumber);
            return topUserIdHaveMostPost;
        }

        public IQueryable<ShowPostsHighRating> GetPostsHighRating(int topNumber, IQueryable<UserInteract> userInteracts)
        {
            var validResult = userInteracts.Where(x => x.Rating != null).GroupBy(x => x.PostsId, y => y.Rating)
                                                                        .Select(x => new
                                                                        {
                                                                            PostId = x.Key,
                                                                            AvgRating = x.Average(),
                                                                        });

            var postsHighRating = GetByCondition(x => x.Status == PostStatus.Active).Join(validResult,
                                                                                            x => x.Id, y => y.PostId,
                                                                                            (x, y) => new ShowPostsHighRating
                                                                                            {
                                                                                                Id = x.Id,
                                                                                                AverageRating = Math.Round((decimal)y.AvgRating),
                                                                                                ImageUrl = x.ImageUrl,
                                                                                                Name = x.Name,
                                                                                                CreateDate = x.CreateDate
                                                                                            })
                                                                                            .OrderByDescending(x => x.AverageRating)
                                                                                            .Take(topNumber);
            return postsHighRating;
        }
    }
}
