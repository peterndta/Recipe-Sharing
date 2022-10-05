﻿namespace reciWebApp.DTOs
{
    public class UpdatePostDTO
    {
        public string? Name { get; set; }
        public int? CookingMethodId { get; set; }
        public int? RecipeTypeId { get; set; }
        public string? ImageUrl { get; set; }
        public string? VideoUrl { get; set; }
        public int? CategoryId { get; set; }
        public DateTime? UpdateDate { get; } = DateTime.Now;
    }
}